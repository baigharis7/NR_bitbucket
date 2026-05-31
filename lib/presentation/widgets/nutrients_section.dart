import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/vertical_nutrient_widget.dart';

import '../../domain/models/dashboard/nutrients_model.dart';

class NutrientsSection extends StatelessWidget {
  final String? title;
  final List<NutrientsModel> nutrients;
  final Color? titleColor;
  final String? image;
  const NutrientsSection({super.key, this.title, required this.nutrients, this.titleColor, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Image.asset(image ?? 'assets/images/goal_objectives.png', height: 18, width: 18,),
        const SizedBox(width: Dimens.widthXXXXSmall),
        Text(title ?? AppLocalizations.of(context)!.objectives, style: TextStyle(fontWeight: FontWeight.w900, color: titleColor ?? AppColors.peacockBlue, fontSize: Dimens.fontSize13)),
      ],
      ),
      const SizedBox(height: Dimens.height30),
      Row(children: [
        ...nutrients.map((nutrient) => VerticalNutrientWidget(nutrient: nutrient, titleColor: titleColor,)),
      ],)
    ],);
  }

}