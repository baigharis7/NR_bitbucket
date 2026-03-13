import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';


import '../../domain/models/recommendations/recommendations_food_item.dart';

class RecommendationsItem extends StatefulWidget {
  final FoodItemMaster foodItemMaster;
  final Function(RecommendationFoodInfo? recommendationFoodInfo) onAlternativeAdd;
  final Function onAdd;
  final bool isChecked;
  final Color? checkBoxColor;
  final bool? isFrequent;
  final List<RecommendationFoodInfo>? alternativeUsualHealthyFoods;
  final bool? Function(int id) isAlternativeChecked;

  const RecommendationsItem({
    Key? key,
    required this.foodItemMaster,
    required this.onAlternativeAdd,
    required this.onAdd,
    required this.isChecked,
    this.checkBoxColor,
    this.isFrequent = false,
    this.alternativeUsualHealthyFoods,
    required this.isAlternativeChecked,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsItemState();
}

class _RecommendationsItemState extends State<RecommendationsItem> {
  void _showAlternativesSheet() {
    final alternatives = widget.alternativeUsualHealthyFoods.orEmpty();
    if (alternatives.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.floralWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimens.border20),
            topRight: Radius.circular(Dimens.border20),
          ),
        ),
        padding: const EdgeInsets.all(Dimens.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.yellowishGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Dimens.height12),
            Text(
              AppLocalizations.of(context)!.alternatives,
              style: AppTextStyles.merriWeather.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Dimens.fontSizeNormal,
                color: AppColors.yellowishGreen,
              ),
            ),
            const SizedBox(height: Dimens.height12),
            ...alternatives.map((alt) {
              final isSelected = widget.isAlternativeChecked.call(alt.foodItemMaster.id ?? -1) ?? false;
              return GestureDetector(
                onTap: () {
                  widget.onAlternativeAdd.call(alt);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: Dimens.marginSmall),
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimens.paddingNormal,
                    horizontal: Dimens.paddingNormal,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (widget.checkBoxColor ?? AppColors.yellowishGreen).withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(Dimens.border15),
                    border: Border.all(
                      color: isSelected
                          ? widget.checkBoxColor ?? AppColors.yellowishGreen
                          : AppColors.yellowishGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.checkBoxColor ?? AppColors.yellowishGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: Dimens.width12),
                      Expanded(
                        child: Text(
                          alt.foodItemMaster.translate(context),
                          style: AppTextStyles.merriWeather.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: Dimens.fontSize13,
                            color: AppColors.yellowishGreen,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: widget.checkBoxColor ?? AppColors.yellowishGreen, size: 20),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.checkBoxColor ?? AppColors.yellowishGreen;
    final hasAlternatives = widget.alternativeUsualHealthyFoods.orEmpty().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingSmall,
        vertical: 3,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.border15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color strip on left edge
            Container(
              width: 7,
              color: color,
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: Dimens.paddingSmall,
                ),
                child: Row(
                  children: [
                    // Food name
                    Expanded(
                      child: Text(
                        widget.foodItemMaster.translate(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: Dimens.fontSize13,
                          color: color,
                        ),
                      ),
                    ),
                    // Alternatives button (only for usual foods)
                    if (hasAlternatives) ...[
                      const SizedBox(width: Dimens.marginSmall),
                      GestureDetector(
                        onTap: _showAlternativesSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: color.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(Dimens.border20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz, size: 16, color: color),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.alternatives,
                                style: AppTextStyles.merriWeather.copyWith(
                                  fontSize: Dimens.fontSizeXSmall,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Add / check button
                    const SizedBox(width: Dimens.marginSmall),
                    GestureDetector(
                      onTap: () => widget.onAdd.call(),
                      child: Icon(
                        widget.isChecked ? Icons.check_circle : Icons.add_circle_outline,
                        color: widget.isChecked ? AppColors.green : color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
