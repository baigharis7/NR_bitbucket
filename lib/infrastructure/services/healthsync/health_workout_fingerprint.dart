import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_type_normalizer.dart';

/// Immutable identity fingerprint of one workout, independent of which app
/// or device recorded it.
///
/// LOCKED CONTRACT (Wave 3 design, 2026-07-18): the dedupe strong tier
/// compares these fields, and T14's imported-event-id factory consumes
/// [stableHash] — do not rename fields or change the hash recipe.
///
/// Plain immutable class — no `==`/`hashCode` override (the codebase uses
/// neither `equatable` nor `freezed`); [stableHash] is a domain value, not
/// an equality override.
class HealthWorkoutFingerprint {
  /// Workout type normalized via [HealthWorkoutTypeNormalizer].
  final String normalizedType;

  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  /// Coarse source category ([HealthSourceResolver]) — carried for
  /// diagnostics/metadata, deliberately NOT part of [stableHash].
  final HealthSourceCategory sourceCategory;

  const HealthWorkoutFingerprint({
    required this.normalizedType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.sourceCategory,
  });

  factory HealthWorkoutFingerprint.fromActivity(HealthActivity activity) {
    return HealthWorkoutFingerprint(
      normalizedType: HealthWorkoutTypeNormalizer.normalize(
        activity.activityType,
      ),
      startTime: activity.startTime,
      endTime: activity.endTime,
      durationMinutes: activity.durationMinutes,
      sourceCategory: HealthSourceResolver.resolve(
        sourceName: activity.sourceName,
        sourceType: activity.sourceType,
      ),
    );
  }

  static const int _fnvOffsetBasis = 0x811C9DC5;
  static const int _fnvPrime = 0x01000193;

  /// FNV-1a 32-bit hash over `'$normalizedType|$startMs|$endMs'`.
  ///
  /// The source is deliberately excluded: the hash identifies workout
  /// CONTENT, and two sources recording the same workout must hash
  /// identically. Deterministic across devices and reinstalls — T14 derives
  /// imported event ids from it, so the recipe must never change.
  int get stableHash {
    final input =
        '$normalizedType|${startTime.millisecondsSinceEpoch}|'
        '${endTime.millisecondsSinceEpoch}';
    var hash = _fnvOffsetBasis;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * _fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }
}
