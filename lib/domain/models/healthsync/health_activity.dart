/// Represents an activity synced from a health platform (HealthKit or Health Connect).
/// This is a domain model used before converting to SportEventComplete.
class HealthActivity {
  /// Unique identifier from the health platform (uuid)
  final String healthPlatformId;

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
