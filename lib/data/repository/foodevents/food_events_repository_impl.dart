import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_calculation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class FoodEventsRepositoryImpl extends FoodEventsRepository {
  final LocalStorageRepository localStorageRepository;
  final FoodEventsApi foodEventsApi;
  final NutrientCalculationService nutrientCalculationService;
  final SyncQueueService syncQueue;

  FoodEventsRepositoryImpl({
    required this.localStorageRepository,
    required this.foodEventsApi,
    required this.nutrientCalculationService,
    required this.syncQueue,
  });

  @override
  Future<void> saveFoodEvent(UploadFoodEvent uploadFoodEvent, bool isEdit) async {
    final foodEventEntity = mapToFoodEventEntity(uploadFoodEvent);
    localStorageRepository.saveFoodEvent(foodEventEntity, isEdit);
  }

  @override
  Future<UploadFoodEvent> uploadFoodEvent(FoodEventSimple foodEventSimple) async {
    // Pre-process unit equivalences (same as before)
    final ingredients = foodEventSimple.ingredients!.map((ingredient) =>
        FoodInEvent(
            id: ingredient.id,
            qty: getQuantityWithOtherUnits(
                ingredient.qty,
                ingredient.unit,
                ingredient.unitsEquivalences.orEmpty(),
            ),
            unit: ingredient.unit,
            conversionFactor: ingredient.conversionFactor,
            cookingMethod: ingredient.cookingMethod,
          usedOil: ingredient.usedOil,
        ),
    );
    foodEventSimple.ingredients = ingredients.toList();

    // Fetch reference data from Hive for the calculation
    final unitsFoodsEntity = await localStorageRepository.getMasterFile(MasterFilesType.unitsFoods);
    final convFactorsInfoEntity = await localStorageRepository.getMasterFile(MasterFilesType.conversionFactorsInfo);

    final unitsFoods = (unitsFoodsEntity as UnitsFoodsEntity?)?.data ?? [];
    final convFactorsInfo = (convFactorsInfoEntity as ConversionFactorsInfoEntity?)?.data ?? [];

    // Compute enrichment locally (replaces blocking Lambda call)
    final enrichedEvent = await nutrientCalculationService.enrichFoodEvent(
      foodEventSimple,
      unitsFoods: unitsFoods,
      conversionFactorsInfo: convFactorsInfo,
    );

    // Fire background API call for DynamoDB persistence (don't block UI)
    _syncToBackend(enrichedEvent);

    return enrichedEvent;
  }

  void _syncToBackend(UploadFoodEvent uploadFoodEvent) {
    foodEventsApi.saveFoodEvent(uploadFoodEvent).catchError((error) {
      syncQueue.enqueue('/food-event', uploadFoodEvent);
      return <String, dynamic>{};
    });
  }

  @override
  Future<List<FoodEventComplete>> getAllFoodEvents() async {
    final List allEvents = await localStorageRepository.getAllFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<FoodEventComplete> getLastFoodEvent() => localStorageRepository.getLastFoodEvent();

  @override
  Future<List<FoodEventComplete>> getFoodEventsOfToday({DateTime? dateTime}) async {
    final List allEvents = await localStorageRepository.getFoodEventsOfToday(dateTime: dateTime);
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<List<FoodEventComplete>> getWeekFoodEvents() async {
    final List allEvents = await localStorageRepository.getWeekFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<List<FoodEventComplete>> getRecentFoodEvents() async {
    final List allEvents = await localStorageRepository.getRecentFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<bool> removeFoodEvent(FoodEventComplete foodEventComplete) async {
    try {
      final removeFoodEvent = await localStorageRepository.removeFoodEvent(foodEventComplete);
      return true;
    } catch (_) {
      throw false;
    }
  }

  @override
  Future<bool> deleteFoodEvent(String userId, int eventDate) async {
    foodEventsApi.deleteFoodEvent(userId, eventDate).catchError((error) {
      syncQueue.enqueueDelete('/food-event', {'userId': userId, 'eventId': eventDate});
      return <String, dynamic>{};
    });
    return true;
  }
}
