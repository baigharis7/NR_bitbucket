import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class FavoritesHelper {

  FavoritesHelper();

  MealTime? getMealTimeByName(String name) {
    if (name == AppLocalizationsHelper.instance.translate('breakfast')) {
      return Breakfast();
    } else if (name == AppLocalizationsHelper.instance.translate('lunch')) {
      return Lunch();
    } else if (name == AppLocalizationsHelper.instance.translate('dinner')) {
      return Dinner();
    } else if (name == AppLocalizationsHelper.instance.translate('snack')) {
      return Snack();
    } else {
      return null;
    }
  }
}