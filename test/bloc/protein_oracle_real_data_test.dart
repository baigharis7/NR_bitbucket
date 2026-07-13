import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_calculation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

/// B1 · Workstream B — Oráculo externo con dato real.
///
/// Fixture: test/fixtures/nutrients_real_subset.json — 5 alimentos copiados
/// VERBATIM de s3://nutrients-pro/nutrients.json (últ. mod. 4-may-2026,
/// extraído 13-jul-2026). Esperados: guía de testeo de la experta de dominio
/// ("Cálculo de Macros por Consumo Real": valor_total = valor_100g × g ÷ 100,
/// columna autoritativa de proteína = proteinLabel/AP).
///
/// El grupo "lo que muestra la app" NACE EN ROJO (B1): el dashboard suma la
/// columna proteinSci, vacía en el 25% del catálogo. Se pone verde con el fix
/// de B2 SIN MODIFICAR estos tests. Si hay que tocar este fichero para que
/// pase, el fix es incorrecto.
///
/// Tolerancia ±0.06: los esperados de la guía vienen redondeados a 1 decimal.

class _Caso {
  final int foodId;
  final String nombre;
  final int gramos;
  final double proteina;
  final double? kcal;
  final double? grasa;
  final double? hidratos;

  const _Caso(this.foodId, this.nombre, this.gramos, this.proteina,
      {this.kcal, this.grasa, this.hidratos});
}

const _casos = [
  _Caso(2050, 'Tortilla francesa', 60, 8.8, kcal: 101.8, grasa: 7.4, hidratos: 0.2),
  _Caso(1745, 'Jamón serrano', 250, 76.3, kcal: 407.5, grasa: 11.3),
  _Caso(1870, 'Chuleta de cerdo', 300, 57.0, kcal: 633.0, grasa: 45.0, hidratos: 0.0),
  _Caso(305, 'Pasta', 90, 12.2, hidratos: 65.2),
  _Caso(156, 'Arroz integral', 80, 7.6, hidratos: 57.4),
];

const _tolerancia = 0.06;

/// Entradas reales (nombres actuales) del master de nutrientes — la UI resuelve
/// nombre/unidad del macro contra esto.
final _nutrientsInfoReal = [
  NutrientInfoMaster(officialName: 'proteinSci', unit: 'g', en: 'Protein', es: 'Proteínas'),
  NutrientInfoMaster(officialName: 'proteinLabel', unit: 'g', en: 'Protein labeling', es: 'Etiquetado de proteínas'),
  NutrientInfoMaster(officialName: 'carbsAvailable', unit: 'g', en: 'Carbohydrates', es: 'Hidratos'),
  NutrientInfoMaster(officialName: 'fatTotal', unit: 'g', en: 'Fat', es: 'Grasas'),
];

class _FakeProfileComputationService extends Fake implements ProfileComputationService {
  @override
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(List<int> objectiveIds) async => null;
}

void main() {
  late ReferenceDatabase db;
  late NutrientCalculationService service;
  late List<dynamic> fixtureFoods;

  setUpAll(() {
    final raw = File('test/fixtures/nutrients_real_subset.json').readAsStringSync();
    fixtureFoods = (jsonDecode(raw) as Map<String, dynamic>)['foods'] as List<dynamic>;
  });

  setUp(() async {
    db = ReferenceDatabase(NativeDatabase.memory());
    service = NutrientCalculationService(db);
    for (final food in fixtureFoods) {
      await db.into(db.nutrientCompositions).insert(NutrientCompositionsCompanion(
            foodId: Value(int.parse(food['id'].toString())),
            isFood: Value(int.tryParse(food['isFood'].toString()) ?? 1),
            group: Value(food['group']?.toString() ?? ''),
            nameEn: Value(food['name_en']?.toString() ?? ''),
            nameEs: Value(food['name_es']?.toString() ?? ''),
            recommendable: Value(int.tryParse(food['recommendable'].toString()) ?? 1),
            freeSugar: Value(food['freeSugar']?.toString()),
            params: Value(jsonEncode(food['params'])),
          ));
    }
  });

  tearDown(() async {
    await db.close();
  });

  /// Registro real: qty en gramos (unidad 38 = par base "38,1" que llevan
  /// todos los alimentos del catálogo), en crudo (cookingMethod -1, sin
  /// factor de conversión). Camino de producción completo: motor de cálculo
  /// → mapper a entity (Hive) → mapper a domain.
  Future<FoodEventComplete> enrichAsComplete(int foodId, int gramos) async {
    final simple = FoodEventSimple(
      userId: 'user123',
      eventId: foodId,
      eventDate: 20260713,
      mealType: 0,
      foodName: null,
      comment: null,
      ingredients: [
        FoodInEvent(id: foodId, qty: gramos, unit: 38, cookingMethod: -1),
      ],
    );
    final upload = await service.enrichFoodEvent(
      simple,
      unitsFoods: [UnitFoodEntity(id: foodId, units: '38,1')],
      conversionFactorsInfo: [],
    );
    return mapToFoodEventComplete(mapToFoodEventEntity(upload));
  }

  group('Guarda del dato real: el motor y los mappers producen proteinLabel correcta', () {
    // Este grupo está VERDE ya en B1: demuestra que el dato y el cálculo son
    // correctos de punta a punta. El bug no está aquí — está en qué columna
    // lee la capa de UI (grupo siguiente).
    for (final c in _casos) {
      test('${c.nombre} ${c.gramos} g → proteinLabel ${c.proteina} g', () async {
        final complete = await enrichAsComplete(c.foodId, c.gramos);
        final params = complete.foodInfo!.single.params!.toJson();

        expect(params['proteinLabel'], closeTo(c.proteina, _tolerancia));
        if (c.kcal != null) expect(params['energyKcal'], closeTo(c.kcal!, _tolerancia));
        if (c.grasa != null) expect(params['fatTotal'], closeTo(c.grasa!, _tolerancia));
        if (c.hidratos != null) expect(params['carbsAvailable'], closeTo(c.hidratos!, _tolerancia));
      });
    }
  });

  group('Oráculo de la experta: la proteína QUE MUESTRA LA APP', () {
    // NACE EN ROJO (B1). El bloc de detalle de comidas construye los macros
    // con la misma lista/clave que dashboard, weekly y detalle de macros:
    // hoy suma proteinSci (0 en estos alimentos) en vez de proteinLabel.
    late MockGetUserIdInteractor mockGetUserId;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEventsOfToday;
    late MockGetTodayLiquidEventsInteractor mockGetTodayLiquidEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
    late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
    late MockUpdateEventsInteractor mockUpdateEvents;
    late MockPreferencesRepository mockPreferencesRepository;

    setUp(() {
      mockGetUserId = MockGetUserIdInteractor();
      mockGetFoodEventsOfToday = MockGetFoodEventsOfTodayInteractor();
      mockGetTodayLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
      mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
      mockPreferencesRepository = MockPreferencesRepository();
    });

    /// Monta el bloc real con el evento enriquecido y devuelve los macros
    /// que la pantalla pintaría (proteína, hidratos, grasa — en ese orden).
    Future<List<double>> macrosMostrados(FoodEventComplete event) async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
      when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo))
          .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: _nutrientsInfoReal));
      when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
          .thenAnswer((_) async => FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])));
      when(mockGetMasterFile.execute(MasterFilesType.unitsInfo))
          .thenAnswer((_) async => UnitsInfoMaster(unitsInfoMaster: []));
      when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo))
          .thenAnswer((_) async => ObjectivesInfoMaster(objectives: [], metabolicObjectives: [], bodyCompositionObjectives: []));
      when(mockGetFoodEventsOfToday.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => [event]);
      when(mockGetTodayLiquidEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockUpdateEvents.execute(
              userId: anyNamed('userId'),
              categoryType: anyNamed('categoryType'),
              fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);

      final bloc = MealTimeDetailsBloc(
        getUserIdInteractor: mockGetUserId,
        getFoodEventsOfTodayInteractor: mockGetFoodEventsOfToday,
        getLiquidEventsOfTodayInteractor: mockGetTodayLiquidEvents,
        getProfileInteractor: mockGetProfile,
        getMasterFileInteractor: mockGetMasterFile,
        deleteFoodEventInteractor: mockDeleteFoodEvent,
        removeFoodEventInteractor: mockRemoveFoodEvent,
        updateEventsInteractor: mockUpdateEvents,
        preferencesRepository: mockPreferencesRepository,
        profileComputationService: _FakeProfileComputationService(),
      );

      bloc.add(UpdateFoodArgumentsModelEventState(
        foodArgumentsModel: FoodArgumentsModel(
          mealTime: MealTime(id: 0, name: 'Desayuno', time: '07:30'),
          selectedDateTime: DateTime(2026, 7, 13),
        ),
      ));
      await pumpEventQueue();

      final macros = bloc.state.macronutrients;
      await bloc.close();

      expect(macros, isNotNull, reason: 'El bloc no llegó a construir los macros');
      expect(macros!.length, 3);
      return macros.map((m) => m.quantityConsumed).toList();
    }

    for (final c in _casos) {
      test('${c.nombre} ${c.gramos} g → la app muestra ${c.proteina} g de proteína', () async {
        final event = await enrichAsComplete(c.foodId, c.gramos);
        final macros = await macrosMostrados(event);

        expect(
          macros[0],
          closeTo(c.proteina, _tolerancia),
          reason: 'Oráculo de la experta: ${c.nombre} ${c.gramos} g debe mostrar '
              '${c.proteina} g de proteína. Si sale otra cosa (típicamente 0.0 o '
              'un valor menor), la UI está sumando proteinSci en vez de '
              'proteinLabel (Workstream B, spec B2).',
        );
        // Controles: hidratos y grasa se muestran desde la columna correcta y
        // NO deben moverse ni antes ni después del fix.
        if (c.hidratos != null) expect(macros[1], closeTo(c.hidratos!, _tolerancia));
        if (c.grasa != null) expect(macros[2], closeTo(c.grasa!, _tolerancia));
      });
    }
  });
}
