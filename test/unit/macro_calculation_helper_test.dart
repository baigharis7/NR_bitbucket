import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/macro_calculation_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

/// Helper to create a Params object with only the fields needed for testing.
/// All 100+ positional params are null except the ones we set.
Params _makeParams({
  double? proteinLabel,
  double? carbsAvailable,
  double? fatTotal,
  double? fiber,
  double? sugarsTotal,
  double? calcium,
}) {
  return Params(
    null, // alanine
    null, // arginine
    null, // arsenic
    null, // ash
    null, // asparticAcid
    null, // benzoicAcid
    null, // betacaroteneVitA
    null, // c16_0
    null, // c18_0
    null, // c18_1N_9
    null, // c18_2N_6
    null, // c18_3N_3
    null, // cadmium
    calcium, // calcium
    carbsAvailable, // carbsAvailable
    null, // carbsByDiff
    null, // carbsDeclared
    null, // celulose
    null, // chromium
    null, // copper
    null, // cystine
    null, // dryMatter
    null, // energyKcal
    null, // energyKJ
    fatTotal, // fatTotal
    null, // fattyAcidConversionFactor
    null, // fattyAcidsTotal
    fiber, // fiber
    null, // fructose
    null, // glucose
    null, // glutamicAcid
    null, // glycine
    null, // hexose
    null, // histamine
    null, // histidine
    null, // hydroxyproline
    null, // iodine
    null, // iron
    null, // isoleucine
    null, // lead
    null, // leucine
    null, // lignin
    null, // lysine
    null, // magnesium
    null, // manganese
    null, // mercury
    null, // methionine
    null, // monosaccharidesTotal
    null, // nickel
    null, // nitro2protein
    null, // nitrogen
    null, // pentose
    null, // phenylalanine
    null, // phosphorus
    null, // potassium
    null, // proline
    proteinLabel, // proteinLabel
    null, // proteinSci
    null, // selenium
    null, // serin
    null, // sodium
    null, // starch
    sugarsTotal, // sugarsTotal
    null, // sumMonoUnsat
    null, // sumN3FattyAcids
    null, // sumN6FattyAcids
    null, // sumPolyUnsat
    null, // sumSat
    null, // threonine
    null, // tryptophan
    null, // tyrosine
    null, // uronicAcid
    null, // valin
    null, // vitA
    null, // vitB1
    null, // vitB2
    null, // vitB3
    null, // vitB3Eq
    null, // vitB5
    null, // vitB6
    null, // vitB7
    null, // vitB9
    null, // vitB9Free
    null, // vitB12
    null, // vitC
    null, // vitCL
    null, // vitCLDehydro
    null, // vitD
    null, // vitD2
    null, // vitD3
    null, // vitD_25hydroxi
    null, // vitD3_25hydroxi
    null, // vitE
    null, // vitE_alphaTP
    null, // water
    null, // zinc
    null, // other
    null, // saturated
    null, // monounsaturated
    null, // polyunsaturated
    null, // totalTrans
    null, // total
    null, // n3
    null, // n6
    null, // cholesterol
    null, // chloride
    null, // molybdenum
    null, // cobalt
    null, // fluoron
    null, // silicon
    null, // rubidium
    null, // aluminum
    null, // boron
    null, // bromine
    null, // arsenInorganic
    null, // omega3
  );
}

FoodEventComplete _makeFoodEvent({
  List<FoodInfo>? foodInfo,
  int? eventKcals,
}) {
  return FoodEventComplete(
    userId: 'user1',
    eventDate: 1000,
    eventId: 1,
    foodInfo: foodInfo,
    eventKcals: eventKcals,
  );
}

void main() {
  const helper = MacroCalculationHelper();

  // ── getPercentageByMacro ────────────────────────────────────────────

  group('Macro Percentage by Objective (getPercentageByMacro)', () {
    // TS-PROF003a
    test('muscle gain (obj 50): carbs 40%, protein 30%, fat 30%', () {
      expect(helper.getPercentageByMacro('carbsAvailable', [50]), 40);
      expect(helper.getPercentageByMacro('proteinLabel', [50]), 30);
      expect(helper.getPercentageByMacro('fatTotal', [50]), 30);
    });

    // TS-PROF003b
    test('weight loss (obj 51): carbs 40%, protein 30%, fat 30%', () {
      expect(helper.getPercentageByMacro('carbsAvailable', [51]), 40);
      expect(helper.getPercentageByMacro('proteinLabel', [51]), 30);
      expect(helper.getPercentageByMacro('fatTotal', [51]), 30);
    });

    // TS-PROF003c
    test('balanced (obj 52): carbs 50%, protein 20%, fat 30%', () {
      expect(helper.getPercentageByMacro('carbsAvailable', [52]), 50);
      expect(helper.getPercentageByMacro('proteinLabel', [52]), 20);
      expect(helper.getPercentageByMacro('fatTotal', [52]), 30);
    });

    // TS-PROF003d
    test('default (no matching obj): carbs 30%, protein 35%, fat 35%', () {
      expect(helper.getPercentageByMacro('carbsAvailable', []), 30);
      expect(helper.getPercentageByMacro('proteinLabel', []), 35);
      expect(helper.getPercentageByMacro('fatTotal', []), 35);
    });

    test('muscle gain + weight loss (obj 50+51) treated same as either', () {
      // Both 50 and 51 use the same distribution
      expect(helper.getPercentageByMacro('carbsAvailable', [50, 51]), 40);
      expect(helper.getPercentageByMacro('proteinLabel', [50, 51]), 30);
      expect(helper.getPercentageByMacro('fatTotal', [50, 51]), 30);
    });
  });

  // ── getKcalPerGram ──────────────────────────────────────────────────

  group('Kcal per Gram (getKcalPerGram)', () {
    // TS-PROF003f
    test('fat uses 9 kcal/gram', () {
      expect(helper.getKcalPerGram('fatTotal'), 9);
    });

    test('carbs use 4 kcal/gram', () {
      expect(helper.getKcalPerGram('carbsAvailable'), 4);
    });

    test('protein uses 4 kcal/gram', () {
      expect(helper.getKcalPerGram('proteinLabel'), 4);
    });
  });

  // ── getMacroNutrientRda ─────────────────────────────────────────────

  group('Macro RDA in Grams (getMacroNutrientRda)', () {
    // TS-PROF003e: 2000 kcal with muscle gain (obj 50)
    test('calculates protein RDA for 2000 kcal with muscle gain', () {
      // protein: 2000/100 * 30 = 600 kcal → 600/4 = 150g
      final result = helper.getMacroNutrientRda(2000, 'proteinLabel', [50]);
      expect(result, 150);
    });

    test('calculates carbs RDA for 2000 kcal with muscle gain', () {
      // carbs: 2000/100 * 40 = 800 kcal → 800/4 = 200g
      final result = helper.getMacroNutrientRda(2000, 'carbsAvailable', [50]);
      expect(result, 200);
    });

    test('calculates fat RDA for 2000 kcal with muscle gain', () {
      // fat: 2000/100 * 30 = 600 kcal → 600/9 = 66.67 → 66g (truncated)
      final result = helper.getMacroNutrientRda(2000, 'fatTotal', [50]);
      expect(result, 66);
    });

    test('calculates correct RDA for balanced diet (obj 52)', () {
      // carbs: 2500/100 * 50 = 1250 kcal → 1250/4 = 312g
      final result = helper.getMacroNutrientRda(2500, 'carbsAvailable', [52]);
      expect(result, 312);
    });

    test('returns 0 when kcal is 0', () {
      final result = helper.getMacroNutrientRda(0, 'proteinLabel', [50]);
      expect(result, 0);
    });
  });

  // ── getUserKcalSelectiveObjectives ──────────────────────────────────

  group('Objective-based Kcal Adjustment (getUserKcalSelectiveObjectives)', () {
    // TS-PROF003g
    test('+15% for muscle gain (obj 50)', () {
      // 2000 + (2000 ~/ 100 * 15) = 2000 + (20 * 15) = 2000 + 300 = 2300
      final result = helper.getUserKcalSelectiveObjectives(2000, [50]);
      expect(result, 2300);
    });

    // TS-PROF003h
    test('-20% for weight loss (obj 51)', () {
      // 2000 - (2000 ~/ 100 * 20) = 2000 - (20 * 20) = 2000 - 400 = 1600
      final result = helper.getUserKcalSelectiveObjectives(2000, [51]);
      expect(result, 1600);
    });

    // TS-PROF003i
    test('stacks both 50 and 51 simultaneously', () {
      // Step 1: 2000 + (2000 ~/ 100 * 15) = 2000 + 300 = 2300
      // Step 2: 2300 - (2300 ~/ 100 * 20) = 2300 - (23 * 20) = 2300 - 460 = 1840
      final result = helper.getUserKcalSelectiveObjectives(2000, [50, 51]);
      expect(result, 1840);
    });

    test('no objectives returns unchanged kcal', () {
      final result = helper.getUserKcalSelectiveObjectives(2000, []);
      expect(result, 2000);
    });

    test('unrelated objective returns unchanged kcal', () {
      final result = helper.getUserKcalSelectiveObjectives(2000, [52]);
      expect(result, 2000);
    });
  });

  // ── calculateConsumedNutrient ───────────────────────────────────────

  group('Nutrient Aggregation (calculateConsumedNutrient)', () {
    // TS-NUTR001a
    test('sums a single nutrient across food events', () {
      final events = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Apple', 'Manzana', 1,
            EventInfo(null, 100.0, 1, null, null, null),
            _makeParams(proteinLabel: 0.5), null),
        ]),
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 2, 'Chicken', 'Pollo', 1,
            EventInfo(null, 150.0, 1, null, null, null),
            _makeParams(proteinLabel: 31.0), null),
        ]),
      ];

      final result = helper.calculateConsumedNutrient(events, 'proteinLabel');
      expect(result, 31.5);
    });

    // TS-NUTR001b
    test('returns 0 for empty events', () {
      final result = helper.calculateConsumedNutrient([], 'proteinLabel');
      expect(result, 0.0);
    });

    // TS-NUTR001c
    test('rounds to 2 decimal places', () {
      final events = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'A', 'A', 1, null,
            _makeParams(calcium: 1.111), null),
          FoodInfo('group', 2, 'B', 'B', 1, null,
            _makeParams(calcium: 2.222), null),
        ]),
      ];

      final result = helper.calculateConsumedNutrient(events, 'calcium');
      // 1.111 + 2.222 = 3.333 → rounded to 3.33
      expect(result, 3.33);
    });

    test('handles events with null foodInfo', () {
      final events = [
        _makeFoodEvent(foodInfo: null),
      ];

      final result = helper.calculateConsumedNutrient(events, 'proteinLabel');
      expect(result, 0.0);
    });

    test('handles events where nutrient is null in params', () {
      final events = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'A', 'A', 1, null,
            _makeParams(proteinLabel: null), null),
        ]),
      ];

      final result = helper.calculateConsumedNutrient(events, 'proteinLabel');
      expect(result, 0.0);
    });
  });

  // ── calculateConsumedSugar ──────────────────────────────────────────

  group('Sugar Calculation (calculateConsumedSugar)', () {
    // TS-NUTR004a
    test('only counts FREE_SUGAR items', () {
      final foodEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Cola', 'Cola', 1, null,
            _makeParams(sugarsTotal: 39.0),
            Constants.FREE_SUGAR), // freeSugar = '1'
          FoodInfo('group', 2, 'Apple', 'Manzana', 1, null,
            _makeParams(sugarsTotal: 10.0),
            null), // not free sugar — should NOT count
        ]),
      ];

      final result = helper.calculateConsumedSugar(foodEvents, []);
      expect(result, 39.0);
    });

    // TS-NUTR004b
    test('includes both food and liquid events', () {
      final foodEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Cookie', 'Galleta', 1, null,
            _makeParams(sugarsTotal: 15.0), Constants.FREE_SUGAR),
        ]),
      ];
      final liquidEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 2, 'Soda', 'Refresco', 1, null,
            _makeParams(sugarsTotal: 25.0), Constants.FREE_SUGAR),
        ]),
      ];

      final result = helper.calculateConsumedSugar(foodEvents, liquidEvents);
      expect(result, 40.0);
    });

    test('returns 0 when no free sugar items', () {
      final foodEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Apple', 'Manzana', 1, null,
            _makeParams(sugarsTotal: 10.0), null),
        ]),
      ];

      final result = helper.calculateConsumedSugar(foodEvents, []);
      expect(result, 0.0);
    });
  });

  // ── calculateConsumedFiber ──────────────────────────────────────────

  group('Fiber Calculation (calculateConsumedFiber)', () {
    // TS-NUTR004c
    test('sums fiber from all food events', () {
      final foodEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Oats', 'Avena', 1, null,
            _makeParams(fiber: 4.0), null),
        ]),
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 2, 'Beans', 'Judías', 1, null,
            _makeParams(fiber: 6.5), null),
        ]),
      ];

      final result = helper.calculateConsumedFiber(foodEvents);
      expect(result, 10.5);
    });

    test('returns 0 for empty events', () {
      final result = helper.calculateConsumedFiber([]);
      expect(result, 0.0);
    });

    test('handles null fiber values', () {
      final foodEvents = [
        _makeFoodEvent(foodInfo: [
          FoodInfo('group', 1, 'Water', 'Agua', 1, null,
            _makeParams(fiber: null), null),
        ]),
      ];

      final result = helper.calculateConsumedFiber(foodEvents);
      expect(result, 0.0);
    });
  });

  // ── calculateSugarLimit ─────────────────────────────────────────────

  group('Sugar Limit (calculateSugarLimit)', () {
    // TS-NUTR004d
    test('calculates 5% of kcal divided by 4', () {
      // 2000 * 0.05 = 100 kcal → 100 / 4 = 25g
      final result = helper.calculateSugarLimit(2000);
      expect(result, 25);
    });

    test('truncates to integer (floor division)', () {
      // 1800 * 0.05 = 90 kcal → 90 / 4 = 22.5 → 22 (truncated)
      final result = helper.calculateSugarLimit(1800);
      expect(result, 22);
    });

    test('returns 0 for 0 kcal', () {
      final result = helper.calculateSugarLimit(0);
      expect(result, 0);
    });
  });
}
