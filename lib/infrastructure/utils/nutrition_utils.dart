import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../domain/models/favorites/food/food_favorite.dart';
import '../../domain/models/masterfiles/sports_info_master.dart';
import '../../domain/models/masterfiles/units_info_master.dart';

class NutritionUtils {
  static int calculateKcal({required List<FoodEventComplete> foodEvents}) {
    int totalKcal = 0;
    for (FoodEventComplete food in foodEvents) {
      totalKcal = totalKcal + food.eventKcals.orZero();
    }
    return totalKcal;
  }

  static String findFoodsName(
      {List<FoodItemMaster>? foodNames,
      List<dynamic>? ingredients,
      BuildContext? context}) {
    final buffer = StringBuffer();

    for (int i = 0; i < ingredients.orEmpty().length; i++) {
      var foodName = FoodItemMaster.empty();

      foodItemMasterLoop:
      for (FoodItemMaster food in foodNames.orEmpty()) {
        if (food.id == ingredients![i].id) {
          foodName = food;
          break foodItemMasterLoop;
        }
      }

      buffer.write(foodName.translate(context!));

      // Add separator only if not the last item
      if (i < ingredients.orEmpty().length - 1) {
        buffer.write(' - ');
      }
    }
    return buffer.toString();
  }

  static String findUnitName(List<UnitInfoMaster>? unitsInfoMaster,
      List<FoodInfo>? ingredients, BuildContext? context) {
    final buffer = StringBuffer();

    for (int i = 0; i < ingredients.orEmpty().length; i++) {
      var unitName = UnitInfoMaster.empty();
      foodIUnitInfoMasterLoop:
      for (UnitInfoMaster unitInfoMaster in unitsInfoMaster.orEmpty()) {
        if (unitInfoMaster.id == ingredients![i].eventInfo?.unit) {
          unitName = unitInfoMaster;
          break foodIUnitInfoMasterLoop;
        }
      }
      buffer.write(unitName.translate(context!));
      // Add separator only if not the last item
      if (i < ingredients.orEmpty().length - 1) {
        buffer.write(' - ');
      }
    }
    return buffer.toString();
  }

  static String findSportName(
      {List<dynamic>? names,
      List<dynamic>? ingredients,
      BuildContext? context}) {
    final buffer = StringBuffer();

    for (int i = 0; i < ingredients.orEmpty().length; i++) {
      var name = SportInfoMaster.empty();

      foodItemMasterLoop:
      for (SportInfoMaster item in names.orEmpty()) {
        if (item.id == ingredients![i].id) {
          name = item;
          break foodItemMasterLoop;
        }
      }

      buffer.write(name.translate(context!));

      // Add separator only if not the last item
      if (i < ingredients.orEmpty().length - 1) {
        buffer.write(' - ');
      }
    }
    return buffer.toString();
  }

  static int findSportIntensities({List<dynamic>? names, int? id}) {
    // if (sportName == null || sportsInfo.sportsInfoMaster.isEmpty) return null;
    // final sportChosen = names.orEmpty().firstWhere((sport) => sport.id == id);
    SportInfoMaster sportChosen = SportInfoMaster.empty();
    for (SportInfoMaster sportInfo in names.orEmpty()) {
      if (sportInfo.id == id) {
        sportChosen = sportInfo;
        break;
      }
    }
    return sportChosen.mets;
  }

  static int millisecondsToYears(int milliseconds) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
