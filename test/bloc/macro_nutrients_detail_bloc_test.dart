import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  // Regression test for the firstWhere-without-orElse crash in
  // macro_nutrients_detail_bloc.getNutrientInfo (crash_analysis.md, group 1).
  late MacroNutrientsDetailBloc bloc;

  MacroNutrientsDetailBloc buildBloc() => MacroNutrientsDetailBloc(
        getMasterFileInteractor: MockGetMasterFileInteractor(),
        getProfileInteractor: MockGetProfileInteractor(),
        getWeekFoodEventsInteractor: MockGetWeekFoodEventsInteractor(),
      );

  setUp(() {
    bloc = buildBloc();
    bloc.state.nutrientsInfoMaster = NutrientsInfoMaster(nutrientsInfo: [
      NutrientInfoMaster(
          officialName: 'protein', unit: 'g', en: 'Protein', es: 'Proteína'),
    ]);
  });

  tearDown(() => bloc.close());

  group('getNutrientInfo', () {
    test('returns the matching nutrient when it exists', () {
      final info = bloc.getNutrientInfo('protein');
      expect(info.officialName, 'protein');
      expect(info.unit, 'g');
    });

    test('returns a safe default instead of throwing when name is unknown', () {
      expect(() => bloc.getNutrientInfo('unobtainium'), returnsNormally);
      final info = bloc.getNutrientInfo('unobtainium');
      expect(info.officialName, 'unobtainium');
      expect(info.unit, '');
    });
  });
}
