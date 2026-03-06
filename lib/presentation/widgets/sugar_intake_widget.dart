import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class SugarIntakeWidget extends StatelessWidget {
  final String title;
  final String? backgroundImage;
  final double? consumed;
  final double? total;
  final Color? color;
  final LinearGradient? linearGradient;
  // final int consumed = 25;
  // final int total = 38;

  const SugarIntakeWidget({super.key, required this.title, this.backgroundImage, required this.consumed, required this.total, this.color, this.linearGradient});

  @override
  Widget build(BuildContext context) {
    double percent = consumed.orZero() / total.orZero();

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        image: backgroundImage.isNotNull() ? DecorationImage(
          image: AssetImage(backgroundImage!), // Your sugar background image
          fit: BoxFit.cover,
          opacity: 0.35,
        ) : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.merriWeather.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 9.0,
            percent: percent.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${consumed.orZero().ceil()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                ),
                Text(
                  '${AppLocalizations.of(context)!.from} ${total.orZero().toInt()} g',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSizeXSmall, color: AppColors.yellowishGreen),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey.shade500,
            progressColor: color,
            linearGradient: linearGradient,
            rotateLinearGradient: true,
          ),
        ],
      ),
    );
  }
}
