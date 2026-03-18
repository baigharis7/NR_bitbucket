import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

enum _Tier { low, mid, optimal }

class HealthMetricDetailSheet {
  static OverlayEntry? _scrimEntry;
  static OverlayEntry? _menuEntry;
  static OverlayEntry? _plusBtnOverlay;
  static AnimationController? _animController;

  static void show(BuildContext context, HealthImpactMetric metric) {
    if (_menuEntry != null) return;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final info = _getMetricInfo(metric.type);

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
                        'Optimal Value',
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
                        'Reference',
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

_MetricInfo _getMetricInfo(HealthMetricType type) {
  switch (type) {
    case HealthMetricType.cardiovascularHealth:
      return const _MetricInfo(
        indicator: 'Resting HR (beats/min)',
        optimalValue:
            'Resting HR: 60–100 bpm (normal)\n50–60 bpm (athlete)',
        bibliography: 'American Heart Association 2025',
        description:
            'Every step trains your heart like a muscle. Regular walking improves cardiovascular efficiency and significantly reduces your resting heart rate (HR) — a clear sign that your heart works better and with less effort. Fewer beats, less cardiac wear, and a lower risk of heart attack.',
        lowRange: '< 5,000 steps',
        lowDescription: 'Heart is overworked',
        lowPercentage: '0%',
        midRange: '5,000–10,000 steps',
        midDescription: 'Moderate improvement',
        midPercentage: '↑ 13%',
        optimalRange: '≥ 10,000 steps',
        optimalDescription: 'Athlete-level efficiency',
        optimalPercentage: '↑ 25%',
      );
    case HealthMetricType.physicalEndurance:
      return const _MetricInfo(
        indicator: 'VO₂ max (ml/kg/min) — Aerobic Capacity',
        optimalValue:
            'VO₂ max: 35–40 ml/kg/min (good)\n> 40 ml/kg/min (excellent)',
        bibliography: 'Journal of Applied Physiology 2024',
        description:
            'VO₂ max measures your aerobic capacity — how much oxygen your muscles can use during intense exercise. The higher it is, the better your performance and the lower your fatigue. Walking more increases your VO₂ max: the heart pumps more blood, the lungs absorb more oxygen, and muscles build more mitochondria — the cellular "power plants." The result is a body that is more efficient at using oxygen and generating energy.',
        lowRange: '< 5,000 steps',
        lowDescription: 'I tire out fast',
        lowPercentage: '0%',
        midRange: '5,000–10,000 steps',
        midDescription: 'Moderate improvement',
        midPercentage: '↑ 15%',
        optimalRange: '≥ 10,000 steps',
        optimalDescription: 'Endurance all day long',
        optimalPercentage: '↑ 30%',
      );
    case HealthMetricType.concentrationFocus:
      return const _MetricInfo(
        indicator: 'Cognitive Function / Working Memory',
        optimalValue: '100% cognition',
        bibliography: 'Nature Neuroscience 2024',
        description:
            'During sleep, the brain\'s glymphatic system clears toxins and consolidates memories. Sleep deprivation reduces key neurotransmitters (acetylcholine, noradrenaline), impairing concentration and decision-making. With 7–8 hours, your mind operates at 100%: sharp focus, strong memory, and rapid learning — with no "brain fog."',
        lowRange: '< 6 hours',
        lowDescription: 'Brain fog, can\'t focus',
        lowPercentage: '↓ 25%',
        midRange: '6–7 hours',
        midDescription: 'I function but not at 100%',
        midPercentage: '↓ 15%',
        optimalRange: '≥ 7 hours',
        optimalDescription: 'Clear mind, laser focus',
        optimalPercentage: '100%',
      );
    case HealthMetricType.muscleRegeneration:
      return const _MetricInfo(
        indicator: 'Tissue Repair (%) / Growth Hormone (GH)',
        optimalValue: '100% repair',
        bibliography: 'J. Clinical Endocrinology 2024',
        description:
            'During deep sleep, the pituitary gland releases the largest daily pulse of growth hormone (GH). GH activates protein synthesis, rebuilding muscles, strengthening skin, and slowing cellular aging. With adequate sleep, you wake up renewed: recovered muscles, firmer skin, and a strong immune system. It is your natural "nightly maintenance."',
        lowRange: '< 6 hours',
        lowDescription: 'I never recover, always sore',
        lowPercentage: '↓ 35%',
        midRange: '6–7 hours',
        midDescription: 'I recover but slowly',
        midPercentage: '↓ 15%',
        optimalRange: '≥ 7 hours',
        optimalDescription: 'I wake up fresh and new',
        optimalPercentage: '100%',
      );
    case HealthMetricType.goodbyeCramps:
      return const _MetricInfo(
        indicator: 'Frequency of Muscle Cramps',
        optimalValue: '< 1 cramp/month',
        bibliography: 'Clinical Journal of Sports Medicine 2024',
        description:
            'Dehydration disrupts the electrolyte balance (sodium, potassium, and magnesium) essential for controlled muscle contraction. Staying well hydrated helps prevent involuntary spasms. With adequate water and proper mineral balance, muscle electrical signals function correctly and cramps are reduced by up to 65%.',
        lowRange: '< 6 glasses',
        lowDescription: 'Frequent cramps',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Occasional cramp',
        midPercentage: '↓ 40%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'No cramps',
        optimalPercentage: '↓ 65%',
      );
    case HealthMetricType.collagenElasticity:
      return const _MetricInfo(
        indicator: 'Skin Hydration (%) / Collagen Fragmentation',
        optimalValue:
            'Hydration: > 40%\nElasticity: > 35%\nCollagen: Intact',
        bibliography: 'Dermatology Research RCT 2024',
        description:
            'Real anti-aging — without expensive creams. Hydrating from within strengthens the extracellular matrix and protects collagen, the structural "scaffold" that gives your skin firmness, elasticity, and structure. With adequate water, collagen remains intact, fibers do not fragment, and skin appears firmer, more luminous, and with less noticeable wrinkles. Visible results in 3–4 weeks.',
        lowRange: '< 6 glasses',
        lowDescription: 'Dry and dull skin',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Visible improvement',
        midPercentage: '↑ 17%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'Radiant skin',
        optimalPercentage: '↑ 32%',
      );
    case HealthMetricType.kidneyHealth:
      return const _MetricInfo(
        indicator: 'Urinary Volume (L/day) / Stone Risk',
        optimalValue: 'Urinary Volume: > 2 L/day',
        bibliography: 'JAMA Network Open 2024',
        description:
            'Your kidneys filter 180 liters of blood every day. Drinking enough water produces dilute urine (> 2 L), facilitates waste elimination, and prevents the formation of kidney stones (mineral crystallization), reducing their risk by up to 65%. Clearer urine = healthier kidneys.',
        lowRange: '< 6 glasses',
        lowDescription: 'Kidneys under strain',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Moderate protection',
        midPercentage: '↑ 30%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'Optimal detox',
        optimalPercentage: '↑ 65%',
      );
  }
}
