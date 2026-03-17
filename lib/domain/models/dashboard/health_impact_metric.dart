enum HealthMetricType {
  cardiovascularHealth,
  physicalEndurance,
  concentrationFocus,
  muscleRegeneration,
  goodbyeCramps,
  collagenElasticity,
  kidneyHealth,
}

class HealthImpactMetric {
  final HealthMetricType type;
  final String label;
  final String sublabel;
  final double percentage;
  final bool isPositive;
  final bool isNeutral;

  const HealthImpactMetric({
    required this.type,
    required this.label,
    required this.sublabel,
    required this.percentage,
    required this.isPositive,
    this.isNeutral = false,
  });
}
