import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class NutrientElementWidget extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final Color? progressColor;
  const NutrientElementWidget({super.key, required this.label, required this.current, required this.goal, required this.unit, this.progressColor});

  @override
  Widget build(BuildContext context) {
    // Guard against goal == 0 (fresh account with no kcal target). NaN.clamp()
    // returns NaN, which propagates into the progress bar and renders wrong.
    final double progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) * 100 : 0.0;
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: current.toNutrientDisplay(),
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize15),
              ),
              TextSpan(
                text: unit,
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
              ),
              TextSpan(
                text: ' / ',
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
              ),
              TextSpan(
                text: '${goal.toInt()}',
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize15),
              ),
              TextSpan(
                text: unit,
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13),
              ),
            ],
          ),
        ),
        AnimatedNutrientProgressBarWidget(percent: progress, title: label.toUpperCase(), width: Dimens.widthNormal, height: Dimens.height12, color: progressColor,),
      ],
    );
  }
}
