/// Canonical workout-type normalization — the ONE normalization in the
/// codebase. T9's fingerprint/dedupe and (later) T13's type mapping both
/// normalize through this helper.
///
/// Deliberately tiny: both platforms already share the
/// `HealthWorkoutActivityType` UPPER_SNAKE_CASE vocabulary, so trim+uppercase
/// is enough. Near-synonym variants (e.g. RUNNING vs RUNNING_TREADMILL) stay
/// distinct — collapsing them risks merging two real workouts (conservative
/// by design; locked decision 2026-07-18).
class HealthWorkoutTypeNormalizer {
  const HealthWorkoutTypeNormalizer._();

  /// Trims and uppercases [raw]; empty or whitespace-only input normalizes
  /// to 'WORKOUT' (the same literal the repository uses when a workout
  /// record carries no `WorkoutHealthValue`).
  static String normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'WORKOUT';
    return trimmed.toUpperCase();
  }
}
