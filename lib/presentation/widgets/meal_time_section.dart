import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import '../../domain/models/favorites/food/meal_time.dart';
import '../foodevent/view/add_food_event_screen.dart';
import 'dash_title_widget.dart';
import 'meal_time_widget.dart';

class MealTimeSection extends StatelessWidget {
  final List<FoodEventComplete> foodEvents;
  final int totalKcal;
  final Function? then;
  const MealTimeSection({super.key, required this.foodEvents, required this.totalKcal, this.then});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DashTitleWidget(title: AppLocalizations.of(context)!.feeding),
      ...MealTime.getAllMealTimes().map((meal) => MealTimeWidget(name: meal.name.orEmpty(), svg: 'assets/images/meal_time_${meal.id.orZero()}.png', onClick: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: meal.id).then((value) => then?.call()), desc: getFoodNames(foodEvents, meal.id) + ' / $totalKcal kcal.',)),
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