import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final String? hint;
  final String? iconAsset;

  const ConfirmationDialog({
    Key? key,
    required this.message,
    this.hint,
    this.iconAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null)
            Image.asset(iconAsset!, height: 52, width: 52)
          else
            const Icon(Icons.check_circle_outline, size: 52, color: Colors.white),
          const SizedBox(height: Dimens.height25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimens.padding20),
            decoration: BoxDecoration(
              color: AppColors.white85Percent,
              borderRadius: BorderRadius.circular(Dimens.border20),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.saved_title,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontSize: Dimens.fontSizeXXLarge,
                    color: AppColors.yellowishGreen,
                  ),
                ),
                const SizedBox(height: Dimens.heightXSmall),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontSize: Dimens.fontSize15,
                    color: AppColors.yellowishGreen,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: Dimens.heightXSmall),
                  Text(
                    hint!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.merriWeather.copyWith(
                      fontSize: 14.0,
                      color: AppColors.yellowishGreen80,
                    ),
                  ),
                ],
                const SizedBox(height: Dimens.heightXSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
