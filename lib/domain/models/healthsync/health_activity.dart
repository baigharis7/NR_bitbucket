/// Represents an activity synced from a health platform (HealthKit or Health Connect).
/// This is a domain model used before converting to SportEventComplete.
class HealthActivity {
  /// Canonical platform identity: the platform record UUID (Health Connect
  /// `metadata.id` / HealthKit `HKObject.uuid`) when the platform provided
  /// one, else [legacyPlatformId]. New sync metadata is keyed by this.
  final String healthPlatformId;

  /// Legacy synthesized identity `'<sourceName>_<startMs>_<endMs>'` — always
  /// computed. Bridges metadata written before the uuid upgrade so existing
  /// users don't re-import (exact-tier dedupe checks BOTH ids).
  final String legacyPlatformId;

  /// Type of activity (e.g., 'WORKOUT', 'RUNNING', 'CYCLING', 'WALKING')
  final String activityType;

  /// When the activity started
  final DateTime startTime;

  /// When the activity ended
  final DateTime endTime;

  /// Duration in minutes
  final int durationMinutes;

  /// Calories burned during the activity
  final double? caloriesBurned;

  /// Distance covered in meters (if applicable)
  final double? distance;

  /// Average heart rate in bpm (if available)
  final int? avgHeartRate;

  /// Name of the source device/app (e.g., 'Apple Watch', 'Samsung Health')
  final String sourceName;

  /// Source type: 'apple_health' or 'health_connect'
  final String sourceType;

  HealthActivity({
    required this.healthPlatformId,
    required this.legacyPlatformId,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.caloriesBurned,
    this.distance,
    this.avgHeartRate,
    required this.sourceName,
    required this.sourceType,
  });

  @override
  String toString() {
    return 'HealthActivity(type: $activityType, duration: ${durationMinutes}min, calories: $caloriesBurned, source: $sourceName)';
  }
}
