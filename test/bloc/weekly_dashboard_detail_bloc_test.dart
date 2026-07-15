import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/bloc/weekly_dashboard_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  // Regression tests for the firstWhere-without-orElse crashes documented in
  // crash_analysis.md (group 1). These methods used to throw StateError when a
  // nutrient/RDA name from the server catalog didn't match the local one,
  // crashing the weekly detail screen for all users on a catalog update.
  late WeeklyDashboardDetailBloc bloc;

  WeeklyDashboardDetailBloc buildBloc() => WeeklyDashboardDetailBloc(
        getWeekFoodEventsInteractor: MockGetWeekFoodEventsInteractor(),
        getUserMicronutrientsInteractor: MockGetUserMicronutrientsInteractor(),
        getUserRdasInteractor: MockGetUserRdasInteractor(),
        getProfileInteractor: MockGetProfileInteractor(),
        getMasterFileInteractor: MockGetMasterFileInteractor(),
        getWeekLiquidEventsInteractor: MockGetWeekLiquidEventsInteractor(),
        getWeekSportsInteractor: MockGetWeekSportsInteractor(),
      );

  setUp(() {
    bloc = buildBloc();
    bloc.state.nutrientsInfoMaster = NutrientsInfoMaster(nutrientsInfo: [
      NutrientInfoMaster(
          officialName: 'iron', unit: 'mg', en: 'Iron', es: 'Hierro'),
    ]);
    bloc.state.userRdas = [
      UserRda(name: 'iron', rda: 10, ul: 0, upperLimit: 0),
    ];
    bloc.state.weeklyFoodEvents = [];
  });

  tearDown(() => bloc.close());

  group('getNutrientInfo', () {
    test('returns the matching nutrient when it exists', () {
      final info = bloc.getNutrientInfo('iron');
      expect(info.officialName, 'iron');
      expect(info.unit, 'mg');
    });

    test('returns a safe default instead of throwing when name is unknown', () {
      expect(() => bloc.getNutrientInfo('unobtainium'), returnsNormally);
      final info = bloc.getNutrientInfo('unobtainium');
      expect(info.officialName, 'unobtainium');
      expect(info.unit, '');
    });
  });

  group('getUnitForMicronutrient', () {
    test('returns the unit when the nutrient exists', () {
      expect(bloc.getUnitForMicronutrient('iron'), 'mg');
    });

    test('returns empty string instead of throwing when name is unknown', () {
      expect(() => bloc.getUnitForMicronutrient('unobtainium'), returnsNormally);
      expect(bloc.getUnitForMicronutrient('unobtainium'), '');
    });
  });

  group('getFractionToFillMicros', () {
    test('returns 0 (no throw) when the RDA is unknown', () {
      expect(() => bloc.getFractionToFillMicros('unobtainium'), returnsNormally);
      expect(bloc.getFractionToFillMicros('unobtainium'), 0);
    });

    test('does not divide by zero when RDA is missing', () {
      final result = bloc.getFractionToFillMicros('unobtainium');
      expect(result.isNaN, isFalse);
      expect(result.isInfinite, isFalse);
    });
  });

  group('getWeeklyMicroNutrientsDataFormatted', () {
    test('never yields NaN even when the RDA is unknown (div-by-zero guard)',
        () {
      final data =
          bloc.getWeeklyMicroNutrientsDataFormatted([], 'unobtainium');
      for (final entry in data) {
        final value = entry['nutrientConsumed'] as num;
        expect(value.isNaN, isFalse);
        expect(value.isInfinite, isFalse);
      }
    });
  });

  group('InitialStateEventAction', () {
    test('builds the weekly macros list from the label-protein column', () async {
      // Macro list pinned to the label-protein column (workstream B).
      final masterInteractor = MockGetMasterFileInteractor();
      when(masterInteractor.execute(MasterFilesType.nutrientsInfo))
          .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: [
                NutrientInfoMaster(
                    officialName: 'proteinLabel',
                    unit: 'g',
                    en: 'Protein',
                    es: 'Proteínas'),
              ]));

      final microsInteractor = MockGetUserMicronutrientsInteractor();
      when(microsInteractor.execute()).thenAnswer((_) async => <String>[]);

      final initBloc = WeeklyDashboardDetailBloc(
        getWeekFoodEventsInteractor: MockGetWeekFoodEventsInteractor(),
        getUserMicronutrientsInteractor: microsInteractor,
        getUserRdasInteractor: MockGetUserRdasInteractor(),
        getProfileInteractor: MockGetProfileInteractor(),
        getMasterFileInteractor: masterInteractor,
        getWeekLiquidEventsInteractor: MockGetWeekLiquidEventsInteractor(),
        getWeekSportsInteractor: MockGetWeekSportsInteractor(),
      );
      addTearDown(initBloc.close);

      initBloc.add(InitialStateEventAction());
      await initBloc.stream.first;

      expect(
        initBloc.state.macronutrientsWeekly!
            .map((m) => m.nutrientInfoMaster.officialName)
            .toList(),
        ['proteinLabel', 'carbsAvailable', 'fatTotal'],
      );
    });
  });
}
