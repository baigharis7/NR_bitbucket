import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SugarIntakeWidget extends StatelessWidget {
  final String title;
  final String? backgroundImage;
  final double? consumed;
  final double? total;
  // final int consumed = 25;
  // final int total = 38;

  const SugarIntakeWidget({super.key, required this.title, this.backgroundImage, required this.consumed, required this.total});

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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
                  '${consumed.orZero().toInt()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context)!.from} ${total.orZero().toInt()} g',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey.shade500,
            progressColor: AppColors.mountainMeadow,
          ),
        ],
      ),
    );
  }
}
