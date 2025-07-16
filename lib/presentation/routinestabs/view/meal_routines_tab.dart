import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

class MealRoutinesTab extends StatelessWidget {
  const MealRoutinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text('Food routines will be shown here....', style: AppTextStyles.subtitle2, textAlign: TextAlign.center),
    ],);
  }

}