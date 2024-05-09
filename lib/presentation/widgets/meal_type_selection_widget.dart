import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../domain/models/favorites/food/meal_time.dart';
import 'box_type_radio_text_widget.dart';

class MealTypeSelectionWidget extends StatefulWidget {
  final Function(int) onSaveMealType;

  const MealTypeSelectionWidget({super.key, required this.onSaveMealType});

  @override
  State<MealTypeSelectionWidget> createState() =>
      _MealTypeSelectionWidgetState();
}

class _MealTypeSelectionWidgetState extends State<MealTypeSelectionWidget> {
  int mealType = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...MealTime.getAllMealTimes().map(
          (mealTime) => BoxTypeRadioTextWidget(
            onPressed: () {
              // mealType = mealTime.id ?? -1;
              widget.onSaveMealType.call(mealTime.id ?? -1);
              // setState(() {});
            },
            isSelected: mealType == mealTime.id,
            title: mealTime.name ?? '',
          ),
        ),
        // RoundedCustomButton(
        //   onPressed: () {
        //     if (mealType != -1) widget.onSaveMealType.call(mealType);
        //   },
        // ),
      ],
    );
  }
}
