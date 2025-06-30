import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfileModel? userProfile;
  final Function? onTapProfileUpdate;
  const ProfileInfoCard({super.key, this.userProfile, this.onTapProfileUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(// Adjust as needed
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellowishGreen80,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: Dimens.width25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile?.commonName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeXLarge, color: Colors.white),
                  ),
                  const SizedBox(height: Dimens.height5),
                  Text(
                    '${userProfile?.sex?.index == SexType.male.index ? AppLocalizations.of(context)!.male : AppLocalizations.of(context)!.female}.${NutritionUtils.millisecondsToYears(userProfile?.birthDate ?? 0)} ${AppLocalizations.of(context)!.years_old}',
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize15, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimens.height32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricItem(value: userProfile?.physicalCharacteristics?.height, label: AppLocalizations.of(context)!.height),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall), color: AppColors.butter59, height: 50, width: 2),
                _MetricItem(value: userProfile?.physicalCharacteristics?.weight, label: AppLocalizations.of(context)!.weight),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall), color: AppColors.butter59, height: 50, width: 2),
                _MetricItem(value: userProfile?.physicalCharacteristics?.bodyFat, label: AppLocalizations.of(context)!.body_fat),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall), color: AppColors.butter59, height: 50, width: 2),
                _MetricItem(value: userProfile?.physicalCharacteristics?.waistMeasurement, label: AppLocalizations.of(context)!.waist),
              ],
            ),
          ),
          const SizedBox(height: Dimens.heightXSmall),
          GestureDetector(
            onTap: () => onTapProfileUpdate?.call(),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.update_data,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: Dimens.fontSizeSmall, color: Colors.white, decoration: TextDecoration.underline),
                ),
                const SizedBox(width: Dimens.width5),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final num? value;
  final String label;

  const _MetricItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          !value.isNull() ? value!.toInt() > 0 ? value!.toInt().toString() : '-' : value.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}
