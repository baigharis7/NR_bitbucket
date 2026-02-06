/// Domain model for tracking which health activities have been synced.
/// Used for deduplication to prevent re-importing the same activity.
class HealthSyncMetadata {
  /// Unique identifier from the health platform (uuid)
  final String healthPlatformId;

  /// Our internal sport event ID
  final int sportEventId;

  /// When this activity was synced
  final DateTime syncedAt;

  /// Source type: 'apple_health' or 'health_connect'
  final String sourceType;

  HealthSyncMetadata({
    required this.healthPlatformId,
    required this.sportEventId,
    required this.syncedAt,
    required this.sourceType,
  });
}
