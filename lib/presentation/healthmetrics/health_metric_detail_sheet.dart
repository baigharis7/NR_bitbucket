import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

enum _Tier { low, mid, optimal }

class HealthMetricDetailSheet {
  static OverlayEntry? _scrimEntry;
  static OverlayEntry? _menuEntry;
  static OverlayEntry? _plusBtnOverlay;
  static AnimationController? _animController;

  static void show(BuildContext context, HealthImpactMetric metric, [SexType? sex]) {
    if (_menuEntry != null) return;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;
    final info = _getMetricInfo(metric.type, l10n, sex);

    final tier = _getCurrentTier(metric);
    final tierColor = tier == _Tier.optimal
        ? AppColors.mountainMeadow
        : tier == _Tier.mid
            ? Colors.orange
            : AppColors.errorRed;
    final tierRange = tier == _Tier.optimal
        ? info.optimalRange
        : tier == _Tier.mid
            ? info.midRange
            : info.lowRange;
    final tierDescription = tier == _Tier.optimal
        ? info.optimalDescription
        : tier == _Tier.mid
            ? info.midDescription
            : info.lowDescription;
    final tierPercentage = tier == _Tier.optimal
        ? info.optimalPercentage
        : tier == _Tier.mid
            ? info.midPercentage
            : info.lowPercentage;

    final overlay = Overlay.of(context);
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
                          _getArrowIcon(metric.type, tier),
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
                                tierDescription,
                                style: AppTextStyles.radioCanadaBig.copyWith(
                                  fontSize: Dimens.fontSizeLarge,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tierRange,
                                style: AppTextStyles.dmSans.copyWith(
                                  fontSize: Dimens.fontSizeNormal,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          tierPercentage,
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

  static IconData _getArrowIcon(HealthMetricType type, _Tier tier) {
    switch (type) {
      // Steps, Collagen, Kidney: low = dash, mid/optimal = up
      case HealthMetricType.cardiovascularHealth:
      case HealthMetricType.physicalEndurance:
      case HealthMetricType.collagenElasticity:
      case HealthMetricType.kidneyHealth:
        if (tier == _Tier.low) return Icons.remove_circle_outline;
        return Icons.arrow_upward;

      // Sleep: optimal = up, low/mid = down
      case HealthMetricType.concentrationFocus:
      case HealthMetricType.muscleRegeneration:
        if (tier == _Tier.optimal) return Icons.arrow_upward;
        return Icons.arrow_downward;

      // Cramps: low = dash, mid/optimal = down (reduction)
      case HealthMetricType.goodbyeCramps:
        if (tier == _Tier.low) return Icons.remove_circle_outline;
        return Icons.arrow_downward;
    }
  }

  static _Tier _getCurrentTier(HealthImpactMetric metric) {
    switch (metric.type) {
      case HealthMetricType.cardiovascularHealth:
      case HealthMetricType.physicalEndurance:
      case HealthMetricType.goodbyeCramps:
      case HealthMetricType.collagenElasticity:
      case HealthMetricType.kidneyHealth:
        if (metric.isNeutral || metric.percentage == 0) return _Tier.low;
        const optimalValues = {
          HealthMetricType.cardiovascularHealth: 25.0,
          HealthMetricType.physicalEndurance: 30.0,
          HealthMetricType.goodbyeCramps: 65.0,
          HealthMetricType.collagenElasticity: 32.0,
          HealthMetricType.kidneyHealth: 65.0,
        };
        return metric.percentage >= optimalValues[metric.type]!
            ? _Tier.optimal
            : _Tier.mid;

      case HealthMetricType.concentrationFocus:
      case HealthMetricType.muscleRegeneration:
        if (metric.isPositive) return _Tier.optimal;
        const midValues = {
          HealthMetricType.concentrationFocus: 15.0,
          HealthMetricType.muscleRegeneration: 15.0,
        };
        return metric.percentage <= midValues[metric.type]!
            ? _Tier.mid
            : _Tier.low;
    }
  }
}

class _MetricInfo {
  final String indicator;
  final String optimalValue;
  final String bibliography;
  final String description;
  final String lowRange;
  final String lowDescription;
  final String lowPercentage;
  final String midRange;
  final String midDescription;
  final String midPercentage;
  final String optimalRange;
  final String optimalDescription;
  final String optimalPercentage;

  const _MetricInfo({
    required this.indicator,
    required this.optimalValue,
    required this.bibliography,
    required this.description,
    required this.lowRange,
    required this.lowDescription,
    required this.lowPercentage,
    required this.midRange,
    required this.midDescription,
    required this.midPercentage,
    required this.optimalRange,
    required this.optimalDescription,
    required this.optimalPercentage,
  });
}

_MetricInfo _getMetricInfo(HealthMetricType type, AppLocalizations l10n, [SexType? sex]) {
  final sleepOptimalRange = sex == SexType.female
      ? l10n.sleep_optimal_range_female
      : l10n.sleep_optimal_range_male;

  switch (type) {
    case HealthMetricType.cardiovascularHealth:
      return _MetricInfo(
        indicator: l10n.metric_indicator_cardiovascular,
        optimalValue: l10n.metric_optimal_cardiovascular,
        bibliography: l10n.metric_bib_cardiovascular,
        description: l10n.metric_desc_cardiovascular,
        lowRange: l10n.steps_low_range,
        lowDescription: l10n.steps_cardio_low_desc,
        lowPercentage: '0%',
        midRange: l10n.steps_mid_range,
        midDescription: l10n.steps_cardio_mid_desc,
        midPercentage: '↑ 13%',
        optimalRange: l10n.steps_optimal_range,
        optimalDescription: l10n.steps_cardio_optimal_desc,
        optimalPercentage: '↑ 25%',
      );
    case HealthMetricType.physicalEndurance:
      return _MetricInfo(
        indicator: l10n.metric_indicator_endurance,
        optimalValue: l10n.metric_optimal_endurance,
        bibliography: l10n.metric_bib_endurance,
        description: l10n.metric_desc_endurance,
        lowRange: l10n.steps_low_range,
        lowDescription: l10n.steps_endurance_low_desc,
        lowPercentage: '0%',
        midRange: l10n.steps_mid_range,
        midDescription: l10n.steps_endurance_mid_desc,
        midPercentage: '↑ 15%',
        optimalRange: l10n.steps_optimal_range,
        optimalDescription: l10n.steps_endurance_optimal_desc,
        optimalPercentage: '↑ 30%',
      );
    case HealthMetricType.concentrationFocus:
      return _MetricInfo(
        indicator: l10n.metric_indicator_concentration,
        optimalValue: l10n.metric_optimal_concentration,
        bibliography: l10n.metric_bib_concentration,
        description: l10n.metric_desc_concentration,
        lowRange: l10n.sleep_low_range,
        lowDescription: l10n.sleep_concentration_low_desc,
        lowPercentage: '↓ 25%',
        midRange: l10n.sleep_mid_range,
        midDescription: l10n.sleep_concentration_mid_desc,
        midPercentage: '↓ 15%',
        optimalRange: sleepOptimalRange,
        optimalDescription: l10n.sleep_concentration_optimal_desc,
        optimalPercentage: '100%',
      );
    case HealthMetricType.muscleRegeneration:
      return _MetricInfo(
        indicator: l10n.metric_indicator_regeneration,
        optimalValue: l10n.metric_optimal_regeneration,
        bibliography: l10n.metric_bib_regeneration,
        description: l10n.metric_desc_regeneration,
        lowRange: l10n.sleep_low_range,
        lowDescription: l10n.sleep_regeneration_low_desc,
        lowPercentage: '↓ 35%',
        midRange: l10n.sleep_mid_range,
        midDescription: l10n.sleep_regeneration_mid_desc,
        midPercentage: '↓ 15%',
        optimalRange: sleepOptimalRange,
        optimalDescription: l10n.sleep_regeneration_optimal_desc,
        optimalPercentage: '100%',
      );
    case HealthMetricType.goodbyeCramps:
      return _MetricInfo(
        indicator: l10n.metric_indicator_cramps,
        optimalValue: l10n.metric_optimal_cramps,
        bibliography: l10n.metric_bib_cramps,
        description: l10n.metric_desc_cramps,
        lowRange: l10n.hydration_low_range,
        lowDescription: l10n.hydration_cramps_low_desc,
        lowPercentage: '0%',
        midRange: l10n.hydration_mid_range,
        midDescription: l10n.hydration_cramps_mid_desc,
        midPercentage: '↓ 40%',
        optimalRange: l10n.hydration_optimal_range,
        optimalDescription: l10n.hydration_cramps_optimal_desc,
        optimalPercentage: '↓ 65%',
      );
    case HealthMetricType.collagenElasticity:
      return _MetricInfo(
        indicator: l10n.metric_indicator_collagen,
        optimalValue: l10n.metric_optimal_collagen,
        bibliography: l10n.metric_bib_collagen,
        description: l10n.metric_desc_collagen,
        lowRange: l10n.hydration_low_range,
        lowDescription: l10n.hydration_collagen_low_desc,
        lowPercentage: '0%',
        midRange: l10n.hydration_mid_range,
        midDescription: l10n.hydration_collagen_mid_desc,
        midPercentage: '↑ 17%',
        optimalRange: l10n.hydration_optimal_range,
        optimalDescription: l10n.hydration_collagen_optimal_desc,
        optimalPercentage: '↑ 32%',
      );
    case HealthMetricType.kidneyHealth:
      return _MetricInfo(
        indicator: l10n.metric_indicator_kidney,
        optimalValue: l10n.metric_optimal_kidney,
        bibliography: l10n.metric_bib_kidney,
        description: l10n.metric_desc_kidney,
        lowRange: l10n.hydration_low_range,
        lowDescription: l10n.hydration_kidney_low_desc,
        lowPercentage: '0%',
        midRange: l10n.hydration_mid_range,
        midDescription: l10n.hydration_kidney_mid_desc,
        midPercentage: '↑ 30%',
        optimalRange: l10n.hydration_optimal_range,
        optimalDescription: l10n.hydration_kidney_optimal_desc,
        optimalPercentage: '↑ 65%',
      );
  }
}
