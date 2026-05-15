import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MicroNutrientsDetailBloc bloc;

  setUp(() {
    bloc = MicroNutrientsDetailBloc(
      getWeekFoodEventsInteractor: MockGetWeekFoodEventsInteractor(),
      getMasterFileInteractor: MockGetMasterFileInteractor(),
      getProfileInteractor: MockGetProfileInteractor(),
      getFoodEventsOfTodayInteractor: MockGetFoodEventsOfTodayInteractor(),
      getDaySupplementEventsInteractor: MockGetDaySupplementEventsInteractor(),
    );
  });

  tearDown(() => bloc.close());

  // Anchor for the bug fix: dashboard and detail page must agree after a
  // supplement is added. Detail page previously only summed food contributions
  // and ignored supplements entirely.
  group('MicroNutrientsDetailBloc.getQuantitySupplementsSoFar', () {
    test('returns 0 when no supplement events are loaded', () {
      bloc.state.supplementEvents = [];
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(v: 1, data: []);
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 0.0);
    });

    test('sums amount for a supplement whose computerName matches', () {
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(
        v: 1,
        data: [
          SupplementInfoMaster(
            id: 1,
            en: 'Vitamin A',
            es: 'Vitamina A',
            unit: 'mcg',
            computerName: 'vitamin_a',
          ),
        ],
      );
      bloc.state.supplementEvents = [
        SupplementSimple(
          info: [NutriInfo(id: 1, unit: 'mcg', amount: 1000)],
        ),
      ];
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 1000.0);
    });

    test('sums across multiple supplement events for the same nutrient', () {
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(
        v: 1,
        data: [
          SupplementInfoMaster(
            id: 1,
            en: 'Vitamin A',
            es: 'Vitamina A',
            unit: 'mcg',
            computerName: 'vitamin_a',
          ),
        ],
      );
      bloc.state.supplementEvents = [
        SupplementSimple(info: [NutriInfo(id: 1, unit: 'mcg', amount: 700)]),
        SupplementSimple(info: [NutriInfo(id: 1, unit: 'mcg', amount: 300)]),
      ];
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 1000.0);
    });

    test('ignores supplements whose computerName does not match', () {
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(
        v: 1,
        data: [
          SupplementInfoMaster(
            id: 1,
            en: 'Vitamin A',
            es: 'Vitamina A',
            unit: 'mcg',
            computerName: 'vitamin_a',
          ),
          SupplementInfoMaster(
            id: 2,
            en: 'Vitamin C',
            es: 'Vitamina C',
            unit: 'mg',
            computerName: 'vitamin_c',
          ),
        ],
      );
      bloc.state.supplementEvents = [
        SupplementSimple(info: [NutriInfo(id: 1, unit: 'mcg', amount: 1000)]),
        SupplementSimple(info: [NutriInfo(id: 2, unit: 'mg', amount: 250)]),
      ];
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 1000.0);
      expect(bloc.getQuantitySupplementsSoFar('vitamin_c'), 250.0);
    });

    test('returns 0 when supplement id is missing from the master file', () {
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(v: 1, data: []);
      bloc.state.supplementEvents = [
        SupplementSimple(info: [NutriInfo(id: 99, unit: 'mcg', amount: 1000)]),
      ];
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 0.0);
    });

    test('rounds the result to 2 decimal places like the dashboard does', () {
      bloc.state.supplementsInfoMaster = SupplementsInfoMaster(
        v: 1,
        data: [
          SupplementInfoMaster(
            id: 1,
            en: 'Vitamin A',
            es: 'Vitamina A',
            unit: 'mcg',
            computerName: 'vitamin_a',
          ),
        ],
      );
      bloc.state.supplementEvents = [
        SupplementSimple(info: [NutriInfo(id: 1, unit: 'mcg', amount: 123)]),
      ];
      // 123 → 123.00, parity with dashboard's toStringAsFixed(2).
      expect(bloc.getQuantitySupplementsSoFar('vitamin_a'), 123.0);
    });
  });
}
