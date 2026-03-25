import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final String? title;
  final String? hint;
  final String? subtitle;
  final String? iconAsset;
  final IconData? iconData;
  final bool showFavoriteTag;
  final bool showRoutineTag;

  const ConfirmationDialog({
    Key? key,
    required this.message,
    this.title,
    this.hint,
    this.subtitle,
    this.iconAsset,
    this.iconData,
    this.showFavoriteTag = false,
    this.showRoutineTag = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
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
                  title ?? AppLocalizations.of(context)!.saved_title,
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
                if (subtitle != null) ...[
                  const SizedBox(height: Dimens.heightXSmall),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.merriWeather.copyWith(
                      fontSize: Dimens.fontSize15,
                      color: AppColors.yellowishGreen80,
                    ),
                  ),
                ],
                if (showFavoriteTag) ...[
                  const SizedBox(height: Dimens.heightXSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 20, color: AppColors.yellowishGreen),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.also_saved_as_favorite,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontSize: Dimens.fontSize15,
                          color: AppColors.yellowishGreen,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showRoutineTag) ...[
                  const SizedBox(height: Dimens.heightXSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 20, color: AppColors.yellowishGreen),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.also_saved_as_routine,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontSize: Dimens.fontSize15,
                          color: AppColors.yellowishGreen,
                        ),
                      ),
                    ],
                  ),
                ],
                if (hint != null) ...[
                  const SizedBox(height: Dimens.heightXSmall),
                  Text(
                    hint!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.merriWeather.copyWith(
                      fontSize: Dimens.fontSize15,
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

  Widget _buildIcon() {
    if (iconData != null) {
      return Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, size: 40, color: AppColors.yellowishGreen),
      );
    }
    if (iconAsset != null) {
      return Image.asset(iconAsset!, height: 65, width: 65);
    }
    return const Icon(Icons.check_circle_outline, size: 65, color: Colors.white);
  }
}
