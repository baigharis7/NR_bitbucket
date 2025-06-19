import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../domain/models/favorites/food/food_favorite.dart';
import '../../domain/models/masterfiles/units_info_master.dart';

class NutritionUtils {

  static int calculateKcal({required List<FoodEventComplete> foodEvents}) {
    int totalKcal = 0;
    for (FoodEventComplete food in foodEvents) {
      totalKcal = totalKcal + food.eventKcals.orZero();
    }
    return totalKcal;
  }

  static String findFoodsName({List<FoodItemMaster>? foodNames, List<dynamic>? ingredients, BuildContext? context}) {
    final buffer = StringBuffer();

    for (int i = 0; i < ingredients.orEmpty().length; i++) {
      // final foodName = foodNames.orEmpty().firstWhere((f) => f.id == ingredients![i].id);
      var foodName = FoodItemMaster();

      foodItemMasterLoop: for (FoodItemMaster food in foodNames.orEmpty()) {
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
    // final item = foodNames.orEmpty().firstWhere((foodItemMaster) => foodId == foodItemMaster.id, orElse: FoodItemMaster.empty);
    // return item.translate(context);
    return buffer.toString();
  }

  static UnitInfoMaster findUnitName(int unitId, List<UnitInfoMaster> unitsInfoMaster) {
    final unitInfo = unitsInfoMaster.firstWhere((unitInfo) => unitInfo.id == unitId, orElse: () => UnitInfoMaster.empty(),);
    if (unitInfo.id == 0) {
      return UnitInfoMaster.empty();
    } else {
      return unitInfo;
    }
  }


}