import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class MacroCalculationHelper {
  const MacroCalculationHelper();

  int getPercentageByMacro(String macro, List<int> objectives) {
    if (objectives.contains(50) || objectives.contains(51)) {
      return macro == 'carbsAvailable' ? 40 : 30;
    } else if (objectives.contains(52)) {
      return macro == 'carbsAvailable' ? 50 : macro == 'proteinSci' ? 20 : 30;
    } else {
      return macro == 'carbsAvailable' ? 30 : 35;
    }
  }

  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;

  int getMacroNutrientRda(int kcal, String macronutrient, List<int> objectives) {
    double kcalPerNutrient = kcal / 100 * getPercentageByMacro(macronutrient, objectives);
    double gramsPerNutrient = kcalPerNutrient / getKcalPerGram(macronutrient);
    return gramsPerNutrient.toInt();
  }

  int getUserKcalSelectiveObjectives(int userKcal, List<int> objectives) {
    int changedKcal = userKcal;

    if (objectives.contains(50)) {
      changedKcal = changedKcal + changedKcal ~/ 100 * 15;
    }
    if (objectives.contains(51)) {
      changedKcal = changedKcal - changedKcal ~/ 100 * 20;
    }

    return changedKcal;
  }

  double calculateConsumedNutrient(List<FoodEventComplete> events, String nutrientName) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in events) {
      for (var food in foodEvent.foodInfo.orEmpty()) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params?.toJson()[nutrientName] ?? 0.0);
      }
    }
    return double.parse(nutrientQuantitySoFar.toStringAsFixed(2));
  }

  double calculateConsumedSugar(List<FoodEventComplete> foodEvents, List<FoodEventComplete> liquidEvents) {
    double sugarConsumedToday = 0.0;
    for (var foodEvent in foodEvents) {
      for (var food in foodEvent.foodInfo.orEmpty()) {
        if (food.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (food.params?.sugarsTotal ?? 0.0);
        }
      }
    }

    for (var liquidEvent in liquidEvents) {
      for (var liquid in liquidEvent.foodInfo.orEmpty()) {
        if (liquid.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
        }
      }
    }

    return double.parse(sugarConsumedToday.toStringAsFixed(2));
  }

  double calculateConsumedFiber(List<FoodEventComplete> foodEvents) {
    double fiberConsumedToday = 0.0;
    for (var foodEvent in foodEvents) {
      for (var food in foodEvent.foodInfo.orEmpty()) {
        fiberConsumedToday = fiberConsumedToday + (food.params?.fiber ?? 0.0);
      }
    }
    return double.parse(fiberConsumedToday.toStringAsFixed(2));
  }

  int calculateSugarLimit(int kcal) {
    return (kcal * 0.05) ~/ 4;
  }
}
