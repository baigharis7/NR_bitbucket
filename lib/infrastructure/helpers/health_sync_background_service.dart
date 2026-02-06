import 'package:workmanager/workmanager.dart';

/// Background service for periodic health data sync using WorkManager.
/// Handles registration and cancellation of background sync tasks.
class HealthSyncBackgroundService {
  static const String healthSyncTaskName = 'com.nutrenaissance.healthSync';
  static const String healthSyncTaskTag = 'healthSyncTask';

  /// Initialize WorkManager. Should be called from main.dart.
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Register a periodic background sync task (~1 hour frequency).
  /// Called when health sync is enabled.
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      healthSyncTaskName,
      healthSyncTaskTag,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }

  /// Cancel the periodic background sync task.
  /// Called when health sync is disabled.
  static Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName(healthSyncTaskName);
  }

  /// Cancel all registered tasks (useful for cleanup).
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}

/// Top-level callback function for WorkManager.
/// This runs in an isolate, so it must re-initialize all dependencies.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == HealthSyncBackgroundService.healthSyncTaskTag) {
      try {
        // Note: Background sync requires re-initializing dependencies in the isolate.
        // This is a simplified implementation. In production, you'd need to:
        // 1. Initialize Hive in the isolate
        // 2. Create all necessary repositories
        // 3. Run the sync logic
        //
        // For now, we'll skip the actual sync in background and rely on
        // foreground sync when the app is opened. This is a common pattern
        // for Flutter apps where background execution has limitations.

        // TODO: Implement full background sync with isolate-safe dependencies
        // This requires careful handling of:
        // - Hive initialization in isolate
        // - Health package initialization
        // - API calls with token refresh
        // - Error handling and retry logic

        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  });
}
