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

  /// Normalized workout type at sync time (T9 fingerprint field). Null on
  /// records written before the fingerprint upgrade — such records are
  /// exact-tier only, never strong-matched.
  final String? normalizedType;

  /// Workout start, epoch milliseconds (fingerprint field). Null pre-upgrade.
  final int? startTimeMs;

  /// Workout end, epoch milliseconds (fingerprint field). Null pre-upgrade.
  final int? endTimeMs;

  /// Coarse source category name ([HealthSourceCategory].name) — never a raw
  /// source display name. Null pre-upgrade.
  final String? sourceCategory;

  /// D10 tombstone — null = live, non-null = the user deleted the imported
  /// event and this platform ID is blocked from re-import.
  final DateTime? deletedAt;

  /// True once [deletedAt] has been set.
  bool get isDeleted => deletedAt != null;

  HealthSyncMetadata({
    required this.healthPlatformId,
    required this.sportEventId,
    required this.syncedAt,
    required this.sourceType,
    this.normalizedType,
    this.startTimeMs,
    this.endTimeMs,
    this.sourceCategory,
    this.deletedAt,
  });
}
