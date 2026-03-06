import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';

import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class RowSugarFiberWidget extends StatelessWidget {
  final double totalValue;
  final double consumedValue;
  final double totalConsumedValue;
  final String title;
  const RowSugarFiberWidget({super.key, required this.totalValue, required this.consumedValue, required this.totalConsumedValue, required this.title});

  @override
  Widget build(BuildContext context) {
    double progress = consumedValue * 100;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
      color: AppColors.darkJungleGreen,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingLarge),
          child: Column(
            children: [
              Text('$totalConsumedValue', style: const TextStyle(fontSize: Dimens.fontSizeXXLarge, fontWeight: FontWeight.bold, color: Colors.white),),
              Text('${AppLocalizations.of(context)!.from} ${totalValue.toInt()} g', style: const TextStyle(color: Colors.white70),),
              AnimatedNutrientProgressBarWidget(percent: progress, title: title, width: 150, height: Dimens.height12),
            ],
          ),
      ),
    );
  }

}