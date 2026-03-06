import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import '../../domain/models/favorites/food/meal_time.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import '../foodevent/view/add_food_event_screen.dart';
import '../mealtimedetails/view/meal_time_details_screen.dart';
import 'dash_title_widget.dart';
import 'meal_time_widget.dart';

class MealTimeSection extends StatelessWidget {
  final List<FoodEventComplete> foodEvents;
  final int totalKcal;
  final Function? then;
  final DateTime selectedDateTime;
  const MealTimeSection({super.key, required this.foodEvents, required this.totalKcal, this.then, required this.selectedDateTime});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DashTitleWidget(title: AppLocalizations.of(context)!.feeding, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20)),
      ...MealTime.getAllMealTimes().map((meal) => MealTimeWidget(name: meal.name.orEmpty(), svg: 'assets/images/meal_time_${meal.id.orZero()}.png', onItemClick: () => Navigator.pushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: meal, selectedDateTime: selectedDateTime)), onClick: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: FoodArgumentsModel(mealTime: meal, selectedDateTime: selectedDateTime)), desc: getFoodNames(foodEvents, meal.id) + ' / $totalKcal kcal.',)),
    ],);
  }

  String getFoodNames(List<FoodEventComplete> foodEvents, int? id) {
    final filteredFoodEvents = foodEvents.where((element) => element.mealType == id).toList();
    var foodKcal = 0;
    if (filteredFoodEvents.isNotEmpty) {
      for (FoodEventComplete food in filteredFoodEvents) {
        foodKcal = foodKcal + food.eventKcals.orZero();
      }
    }
    return foodKcal.toString();
  }
}