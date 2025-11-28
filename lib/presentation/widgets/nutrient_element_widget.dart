import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NutrientElementWidget extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final Color? progressColor;
  const NutrientElementWidget({super.key, required this.label, required this.current, required this.goal, required this.unit, this.progressColor});

  @override
  Widget build(BuildContext context) {
    double progress = (current / goal).clamp(0.0, 1.0) * 100;
    return Column(
      children: [
        AnimatedNutrientProgressBarWidget(percent: progress, title: label.toUpperCase(), width: Dimens.widthNormal, height: Dimens.height12, color: progressColor,),
        Text('${current.ceil()}', style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeXXLarge),),
        Text('${AppLocalizations.of(context)!.from} ${goal.toInt()}$unit', style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize11, color: Colors.white70),),
      ],
    );
  }
}