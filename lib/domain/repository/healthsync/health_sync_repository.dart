import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';

/// Repository interface for health platform integration.
/// Handles communication with HealthKit (iOS) and Health Connect (Android).
abstract class HealthSyncRepository {
  /// Check if health data sync is available on this device.
  /// Returns false if the platform doesn't support health data or Health Connect isn't installed.
  Future<bool> isHealthSyncAvailable();

  /// Request permissions to read health data from the platform.
  /// Returns true if all required permissions were granted.
  Future<bool> requestPermissions();

  /// Check if the app already has the required health data permissions.
  Future<bool> hasPermissions();

  /// Fetch workout activities from the health platform.
  /// Returns activities between [startDate] and [endDate].
  Future<List<HealthActivity>> fetchActivities({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save sync metadata to track which activities have been imported.
  Future<void> saveHealthSyncMetadata(HealthSyncMetadata metadata);

  /// Get all synced activity metadata for deduplication.
  Future<List<HealthSyncMetadata>> getSyncedMetadata();

  /// Check if a specific health platform activity has already been synced.
  Future<bool> isAlreadySynced(String healthPlatformId);

  /// Delete sync metadata for a sport event so it can be re-synced.
  Future<void> deleteSyncMetadataBySportEventId(int sportEventId);

  /// Enable or disable health data sync.
  Future<void> setHealthSyncEnabled(bool enabled);

  /// Check if health data sync is currently enabled by the user.
  Future<bool> isHealthSyncEnabled();

  /// Get the timestamp of the last successful sync.
  Future<DateTime?> getLastSyncTime();

  /// Update the last sync timestamp.
  Future<void> setLastSyncTime(DateTime time);

  /// Install Health Connect app (Android only).
  /// Opens the Play Store to install Health Connect.
  Future<void> installHealthConnect();

  /// Open the Health Connect app (Android only).
  /// Falls back to the Play Store if the app can't be opened directly.
  Future<void> openHealthConnect();

  /// Fetch today's total sleep hours from the health platform.
  /// Returns null if the fetch failed (e.g. permissions revoked, HC error),
  /// so callers can preserve any previously saved value rather than
  /// clobbering it with 0. A real "no data" reading returns 0.0.
  Future<double?> fetchTodaySleepHours(DateTime date);

  /// Fetch today's total step count from the health platform.
  /// Returns null on fetch failure — see fetchTodaySleepHours.
  Future<int?> fetchTodayStepCount(DateTime date);

  /// Save sleep hours for a date to Hive + DynamoDB.
  Future<void> saveSleepEvent({
    required DateTime date,
    required double sleepHours,
  });

  /// Load saved sleep hours for a specific date from Hive.
  Future<double?> getSavedSleepHours(DateTime date);

  /// Save step count for a date to Hive + DynamoDB (reuses StepsEntity).
  Future<void> saveStepEvent({
    required DateTime date,
    required int stepCount,
  });

  /// Load saved step count for a specific date from Hive.
  Future<int?> getSavedStepCount(DateTime date);
}
