import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import '../../domain/models/favorites/food/meal_time.dart';
import '../foodevent/view/add_food_event_screen.dart';
import 'dash_title_widget.dart';
import 'meal_time_widget.dart';

class MealTimeSection extends StatelessWidget {
  const MealTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DashTitleWidget(title: AppLocalizations.of(context)!.feeding),
      ...MealTime.getAllMealTimes().map((meal) => MealTimeWidget(name: meal.name.orEmpty(), svg: 'assets/images/meal_time_${meal.id.orZero()}.png', onClick: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: meal.id), desc: 'Coffe - Toast - Banana ...',)),
    ],);
  }
}