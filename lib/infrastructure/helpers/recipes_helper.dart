import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class RecipesHelper {
  List<String> getIngredientsNames(RecipeMaster recipeMaster, BuildContext context, List<FoodItemMaster> foodNames) {
    return recipeMaster.ingredients.map((recipeIngredient) => getFoodNameByFoodId(recipeIngredient.id, context, foodNames).orEmpty()).toList();
  }

  String? getFoodNameByFoodId(int foodId, BuildContext context, List<FoodItemMaster> foodNames) {
    return foodNames.firstWhere((foodItemMaster) => foodItemMaster.id == foodId).translate(context);
  }

  int? findFoodIdByFoodName(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = foodNames.firstWhere((food) => food.es == foodName);
    } else {
      foodItem = foodNames.firstWhere((food) => food.en == foodName);
    }
    return foodItem.id;
  }
}