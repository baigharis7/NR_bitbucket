import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

// Must match the value used in [CustomBottomNaviBarWidget]. iOS's home-indicator
// safe area (~34pt) is capped here so this popup sits flush with the navbar
// on both platforms.
const double _kIOSNavBottomInset = 16.0;

class HealthMetricDetailSheet {
  static OverlayEntry? _scrimEntry;
  static OverlayEntry? _menuEntry;
  static OverlayEntry? _plusBtnOverlay;
  static AnimationController? _animController;

  static void show(BuildContext context, HealthImpactMetric metric, [SexType? sex]) {
    if (_menuEntry != null) return;

    final overlay = Overlay.of(context);
    final rootMedia = MediaQuery.of(overlay.context);
    final screenHeight = rootMedia.size.height;
    final bottomPadding =
        Platform.isIOS ? _kIOSNavBottomInset : rootMedia.padding.bottom;
    final l10n = AppLocalizations.of(context)!;
    final info = _getMetricInfo(metric.type, l10n, sex);

    final tierIndex = _getCurrentTierIndex(metric);
    final currentTier = info.tiers[tierIndex];
    final isOptimal = tierIndex == info.tiers.length - 1;
    final isLow = tierIndex == 0;
    final tierColor = isOptimal
        ? AppColors.mountainMeadow
        : isLow
            ? AppColors.errorRed
            : Colors.orange;

    _animController = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 300),
    );

    // Scrim stops above the navbar so plus button remains tappable
    _scrimEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 65 + bottomPadding,
        child: GestureDetector(
          onTap: () => hide(),
          behavior: HitTestBehavior.opaque,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animController!,
              curve: Curves.easeInOut,
            ),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );

    _menuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 65 + 8 + bottomPadding,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _animController!,
            curve: Curves.easeInOut,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight - 65 - bottomPadding - 60,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header — full title + percentage
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tierColor.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          _getArrowIcon(metric.type, isOptimal, isLow),
                          color: tierColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          info.indicator,
                          style: AppTextStyles.merriWeather.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: Dimens.fontSizeLarge,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Current tier pill — description as title, range as subtitle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tierColor.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tierColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTier.description,
                                style: AppTextStyles.radioCanadaBig.copyWith(
                                  fontSize: Dimens.fontSizeLarge,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTier.range,
                                style: AppTextStyles.dmSans.copyWith(
                                  fontSize: Dimens.fontSizeNormal,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currentTier.percentage,
                          style: AppTextStyles.radioCanadaBig.copyWith(
                            fontSize: Dimens.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    info.description,
                    style: AppTextStyles.dmSans.copyWith(
                      fontSize: Dimens.fontSizeNormal,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 16),

                  // Optimal value
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 18,
                        color: AppColors.mountainMeadow,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.metric_optimal_value_title,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Dimens.fontSizeNormal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      info.optimalValue,
                      style: AppTextStyles.dmSans.copyWith(
                        fontSize: Dimens.fontSizeNormal,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),

                  // Reference
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.metric_reference_title,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Dimens.fontSizeNormal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      info.bibliography,
                      style: AppTextStyles.dmSans.copyWith(
                        fontSize: Dimens.fontSizeSmall,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );

    _plusBtnOverlay = OverlayEntry(
      builder: (_) => Positioned(
        bottom: bottomPadding + 15,
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: () => hide(),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.greenCyan, AppColors.bluishGreen],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.7],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5015A95F),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );

    overlay.insertAll([_scrimEntry!, _menuEntry!, _plusBtnOverlay!]);
    _animController!.forward();
  }

  static void hide() {
    _animController?.reverse().then((_) {
      _scrimEntry?.remove();
      _scrimEntry = null;
      _menuEntry?.remove();
      _menuEntry = null;
      _plusBtnOverlay?.remove();
      _plusBtnOverlay = null;
      _animController?.dispose();
      _animController = null;
    });
  }

  static IconData _getArrowIcon(HealthMetricType type, bool isOptimal, bool isLow) {
    switch (type) {
      case HealthMetricType.cardiovascularHealth:
      case HealthMetricType.physicalEndurance:
      case HealthMetricType.collagenElasticity:
      case HealthMetricType.kidneyHealth:
        if (isLow) return Icons.remove_circle_outline;
        return Icons.arrow_upward;
      case HealthMetricType.concentrationFocus:
      case HealthMetricType.muscleRegeneration:
        if (isOptimal) return Icons.arrow_upward;
        return Icons.arrow_downward;
      case HealthMetricType.goodbyeCramps:
        if (isLow) return Icons.remove_circle_outline;
        return Icons.arrow_downward;
    }
  }

  /// Returns the index into the metric's tiers list for the current value.
  static int _getCurrentTierIndex(HealthImpactMetric metric) {
    final p = metric.percentage;
    switch (metric.type) {
      // Steps cardio (6 tiers): formula thresholds at 2k/4k/6k/8k/10k boundaries
      case HealthMetricType.cardiovascularHealth:
        if (p <= 0) return 0;
        if (p < 7.5) return 0;   // <2k
        if (p < 15.0) return 1;  // 2-4k
        if (p < 19.5) return 2;  // 4-6k
        if (p < 22.5) return 3;  // 6-8k
        if (p < 25.0) return 4;  // 8-10k
        return 5;                 // ≥10k

      // Steps endurance (6 tiers)
      case HealthMetricType.physicalEndurance:
        if (p <= 0) return 0;
        if (p < 9.0) return 0;   // <2k
        if (p < 15.0) return 1;  // 2-4k
        if (p < 20.5) return 2;  // 4-6k
        if (p < 25.4) return 3;  // 6-8k
        if (p < 30.0) return 4;  // 8-10k
        return 5;                 // ≥10k

      // Sleep concentration deficit (5 tiers, descending — higher deficit = worse)
      case HealthMetricType.concentrationFocus:
        if (metric.isPositive) return 4;  // optimal
        if (p <= 1.7) return 3;           // 7-7.5h
        if (p <= 6.7) return 2;           // 6-7h
        if (p <= 21.0) return 1;          // 5-6h
        return 0;                          // <5h

      // Sleep muscle deficit (5 tiers, descending)
      case HealthMetricType.muscleRegeneration:
        if (metric.isPositive) return 4;  // optimal
        if (p <= 2.2) return 3;           // 7-8h
        if (p <= 6.7) return 2;           // 6-7h
        if (p <= 20.2) return 1;          // 5-6h
        return 0;                          // <5h

      // Cramps & collagen: 3 tiers unchanged
      case HealthMetricType.goodbyeCramps:
        if (p == 0) return 0;
        if (p < 65) return 1;
        return 2;
      case HealthMetricType.collagenElasticity:
        if (p == 0) return 0;
        if (p < 32) return 1;
        return 2;

      // Kidney (5 tiers): formula thresholds at 4/5/7/9/10 boundaries
      case HealthMetricType.kidneyHealth:
        if (p <= 0) return 0;
        if (p < 27.0) return 0;  // <4
        if (p < 42.8) return 1;  // 4-5
        if (p < 58.4) return 2;  // 6-7
        if (p < 61.7) return 3;  // 8-9
        return 4;                 // ≥10
    }
  }
}

class _RangeTier {
  final String range;
  final String description;
  final String percentage;

  const _RangeTier({
    required this.range,
    required this.description,
    required this.percentage,
  });
}

class _MetricInfo {
  final String indicator;
  final String optimalValue;
  final String bibliography;
  final String description;
  final List<_RangeTier> tiers;

  const _MetricInfo({
    required this.indicator,
    required this.optimalValue,
    required this.bibliography,
    required this.description,
    required this.tiers,
  });
}

_MetricInfo _getMetricInfo(HealthMetricType type, AppLocalizations l10n, [SexType? sex]) {
  switch (type) {
    case HealthMetricType.cardiovascularHealth:
      return _MetricInfo(
        indicator: l10n.metric_indicator_cardiovascular,
        optimalValue: l10n.metric_optimal_cardiovascular,
        bibliography: l10n.metric_bib_cardiovascular,
        description: l10n.metric_desc_cardiovascular,
        tiers: [
          _RangeTier(range: l10n.steps_range_1, description: l10n.steps_cardio_desc_1, percentage: '0%'),
          _RangeTier(range: l10n.steps_range_2, description: l10n.steps_cardio_desc_2, percentage: '↑ 8%'),
          _RangeTier(range: l10n.steps_range_3, description: l10n.steps_cardio_desc_3, percentage: '↑ 15%'),
          _RangeTier(range: l10n.steps_range_4, description: l10n.steps_cardio_desc_4, percentage: '↑ 19%'),
          _RangeTier(range: l10n.steps_range_5, description: l10n.steps_cardio_desc_5, percentage: '↑ 23%'),
          _RangeTier(range: l10n.steps_range_6, description: l10n.steps_cardio_desc_6, percentage: '↑ 25%'),
        ],
      );
    case HealthMetricType.physicalEndurance:
      return _MetricInfo(
        indicator: l10n.metric_indicator_endurance,
        optimalValue: l10n.metric_optimal_endurance,
        bibliography: l10n.metric_bib_endurance,
        description: l10n.metric_desc_endurance,
        tiers: [
          _RangeTier(range: l10n.steps_range_1, description: l10n.steps_endurance_desc_1, percentage: '0%'),
          _RangeTier(range: l10n.steps_range_2, description: l10n.steps_endurance_desc_2, percentage: '↑ 9%'),
          _RangeTier(range: l10n.steps_range_3, description: l10n.steps_endurance_desc_3, percentage: '↑ 15%'),
          _RangeTier(range: l10n.steps_range_4, description: l10n.steps_endurance_desc_4, percentage: '↑ 20%'),
          _RangeTier(range: l10n.steps_range_5, description: l10n.steps_endurance_desc_5, percentage: '↑ 25%'),
          _RangeTier(range: l10n.steps_range_6, description: l10n.steps_endurance_desc_6, percentage: '↑ 30%'),
        ],
      );
    case HealthMetricType.concentrationFocus:
      final isFemale = sex == SexType.female;
      return _MetricInfo(
        indicator: l10n.metric_indicator_concentration,
        optimalValue: l10n.metric_optimal_concentration,
        bibliography: l10n.metric_bib_concentration,
        description: l10n.metric_desc_concentration,
        tiers: [
          _RangeTier(range: isFemale ? l10n.sleep_conc_range_1_female : l10n.sleep_conc_range_1, description: l10n.sleep_conc_desc_1, percentage: '↓ 59%'),
          _RangeTier(range: isFemale ? l10n.sleep_conc_range_2_female : l10n.sleep_conc_range_2, description: l10n.sleep_conc_desc_2, percentage: '↓ 21%'),
          _RangeTier(range: isFemale ? l10n.sleep_conc_range_3_female : l10n.sleep_conc_range_3, description: l10n.sleep_conc_desc_3, percentage: '↓ 7%'),
          _RangeTier(range: isFemale ? l10n.sleep_conc_range_4_female : l10n.sleep_conc_range_4, description: l10n.sleep_conc_desc_4, percentage: '↓ 2%'),
          _RangeTier(range: isFemale ? l10n.sleep_conc_range_5_female : l10n.sleep_conc_range_5, description: l10n.sleep_conc_desc_5, percentage: '0%'),
        ],
      );
    case HealthMetricType.muscleRegeneration:
      final isFemale = sex == SexType.female;
      return _MetricInfo(
        indicator: l10n.metric_indicator_regeneration,
        optimalValue: l10n.metric_optimal_regeneration,
        bibliography: l10n.metric_bib_regeneration,
        description: l10n.metric_desc_regeneration,
        tiers: [
          _RangeTier(range: isFemale ? l10n.sleep_regen_range_1_female : l10n.sleep_regen_range_1, description: l10n.sleep_regen_desc_1, percentage: '↓ 20%'),
          _RangeTier(range: isFemale ? l10n.sleep_regen_range_2_female : l10n.sleep_regen_range_2, description: l10n.sleep_regen_desc_2, percentage: '↓ 7%'),
          _RangeTier(range: isFemale ? l10n.sleep_regen_range_3_female : l10n.sleep_regen_range_3, description: l10n.sleep_regen_desc_3, percentage: '↓ 3%'),
          _RangeTier(range: isFemale ? l10n.sleep_regen_range_4_female : l10n.sleep_regen_range_4, description: l10n.sleep_regen_desc_4, percentage: '↓ 1%'),
          _RangeTier(range: isFemale ? l10n.sleep_regen_range_5_female : l10n.sleep_regen_range_5, description: l10n.sleep_regen_desc_5, percentage: '0%'),
        ],
      );
    case HealthMetricType.goodbyeCramps:
      return _MetricInfo(
        indicator: l10n.metric_indicator_cramps,
        optimalValue: l10n.metric_optimal_cramps,
        bibliography: l10n.metric_bib_cramps,
        description: l10n.metric_desc_cramps,
        tiers: [
          _RangeTier(range: l10n.hydration_low_range, description: l10n.hydration_cramps_low_desc, percentage: '0%'),
          _RangeTier(range: l10n.hydration_mid_range, description: l10n.hydration_cramps_mid_desc, percentage: '↓ 40%'),
          _RangeTier(range: l10n.hydration_optimal_range, description: l10n.hydration_cramps_optimal_desc, percentage: '↓ 65%'),
        ],
      );
    case HealthMetricType.collagenElasticity:
      return _MetricInfo(
        indicator: l10n.metric_indicator_collagen,
        optimalValue: l10n.metric_optimal_collagen,
        bibliography: l10n.metric_bib_collagen,
        description: l10n.metric_desc_collagen,
        tiers: [
          _RangeTier(range: l10n.hydration_low_range, description: l10n.hydration_collagen_low_desc, percentage: '0%'),
          _RangeTier(range: l10n.hydration_mid_range, description: l10n.hydration_collagen_mid_desc, percentage: '↑ 17%'),
          _RangeTier(range: l10n.hydration_optimal_range, description: l10n.hydration_collagen_optimal_desc, percentage: '↑ 32%'),
        ],
      );
    case HealthMetricType.kidneyHealth:
      return _MetricInfo(
        indicator: l10n.metric_indicator_kidney,
        optimalValue: l10n.metric_optimal_kidney,
        bibliography: l10n.metric_bib_kidney,
        description: l10n.metric_desc_kidney,
        tiers: [
          _RangeTier(range: l10n.kidney_range_1, description: l10n.kidney_desc_1, percentage: '0%'),
          _RangeTier(range: l10n.kidney_range_2, description: l10n.kidney_desc_2, percentage: '↑ 27%'),
          _RangeTier(range: l10n.kidney_range_3, description: l10n.kidney_desc_3, percentage: '↑ 53%'),
          _RangeTier(range: l10n.kidney_range_4, description: l10n.kidney_desc_4, percentage: '↑ 62%'),
          _RangeTier(range: l10n.kidney_range_5, description: l10n.kidney_desc_5, percentage: '↑ 64%'),
        ],
      );
  }
}
