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

  /// Fetch step count data from the health platform.
  /// Returns step data as HealthActivity entries.
  Future<List<HealthActivity>> fetchSteps({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save sync metadata to track which activities have been imported.
  Future<void> saveHealthSyncMetadata(HealthSyncMetadata metadata);

  /// Get all synced activity metadata for deduplication.
  Future<List<HealthSyncMetadata>> getSyncedMetadata();

  /// Check if a specific health platform activity has already been synced.
  Future<bool> isAlreadySynced(String healthPlatformId);

  /// Enable or disable health data sync.
  Future<void> setHealthSyncEnabled(bool enabled);

  /// Check if health data sync is currently enabled by the user.
  Future<bool> isHealthSyncEnabled();

  /// Get the timestamp of the last successful sync.
  Future<DateTime?> getLastSyncTime();

  /// Update the last sync timestamp.
  Future<void> setLastSyncTime(DateTime time);
}
