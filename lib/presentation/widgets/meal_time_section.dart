import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import '../../domain/models/favorites/food/meal_time.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../foodevent/view/add_food_event_screen.dart';
import '../mealtimedetails/view/meal_time_details_screen.dart';

class MealTimeSection extends StatefulWidget {
  final List<FoodEventComplete> foodEvents;
  final int totalKcal;
  final Function? then;
  final DateTime selectedDateTime;
  final Widget? supplementsCard;
  const MealTimeSection({super.key, required this.foodEvents, required this.totalKcal, this.then, required this.selectedDateTime, this.supplementsCard});

  @override
  State<MealTimeSection> createState() => _MealTimeSectionState();
}

class _MealTimeSectionState extends State<MealTimeSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final meals = MealTime.getAllMealTimes();
    return Column(children: [
      // Collapsible title bar
      GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
          ),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.feeding,
                style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isExpanded ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 22),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      // Collapsible content - 2 column grid
      AnimatedCrossFade(
        firstChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...meals.map((meal) {
                final kcal = getFoodNames(widget.foodEvents, meal.id);
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - Dimens.marginNormal * 2 - 8) / 2,
                  child: _MealTimeGridCard(
                    name: meal.name.orEmpty(),
                    image: 'assets/images/meal_time_${meal.id.orZero()}.png',
                    desc: '$kcal kcal.',
                    onTap: () => Navigator.pushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: meal, selectedDateTime: widget.selectedDateTime)),
                    onAdd: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: FoodArgumentsModel(mealTime: meal, selectedDateTime: widget.selectedDateTime)),
                  ),
                );
              }),
              if (widget.supplementsCard != null)
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width - Dimens.marginNormal * 2 - 8) / 2 + 40,
                      child: widget.supplementsCard!,
                    ),
                  ),
                ),
            ],
          ),
        ),
        secondChild: const SizedBox.shrink(),
        crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 250),
      ),
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

class _MealTimeGridCard extends StatelessWidget {
  final String name;
  final String image;
  final String desc;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _MealTimeGridCard({
    required this.name,
    required this.image,
    required this.desc,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.floralWhite,
          borderRadius: BorderRadius.circular(Dimens.border20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(height: 38, width: 38, child: Image.asset(image)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeMedium, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: Dimens.fontSizeSmall, color: AppColors.battleshipGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 26 * 0.85,
                      height: 26 * 0.85,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const Icon(Icons.add_circle, size: 26, color: AppColors.yellowishGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
