import 'package:workmanager/workmanager.dart';

/// Decommissioned background health sync (Option A decision, 2026-07-20).
///
/// The app deliberately schedules NO closed-app background sync: earlier
/// builds registered an hourly WorkManager task whose dispatcher was a
/// no-op TODO, creating a false sense of background reliability. Health
/// data actually syncs in the foreground only — on app open, via the
/// periodic in-app refresh, and on manual Sync Now — and the product copy
/// now says exactly that.
///
/// Everything left in this file exists solely to clean up after those
/// older builds:
/// - [decommissionLegacyTasks] cancels the legacy hourly task once at
///   startup so upgraded installs stop waking the app for nothing.
/// - [callbackDispatcher] stays as a registered entry point so a stale
///   pre-upgrade task that fires before cancellation completes harmlessly
///   instead of crashing the background isolate.
class HealthSyncBackgroundService {
  static const String healthSyncTaskName = 'com.nutrenaissance.healthSync';

  /// Cancels the periodic task that older builds registered. WorkManager is
  /// initialized first so the dispatcher handle is valid for any stale task
  /// that fires in the meantime. Called once from app bootstrap.
  static Future<void> decommissionLegacyTasks() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().cancelByUniqueName(healthSyncTaskName);
  }
}

/// Handles a background task invocation by succeeding without touching any
/// data. Current builds never schedule a task, so this only runs when a
/// stale pre-upgrade task fires before [HealthSyncBackgroundService
/// .decommissionLegacyTasks] has cancelled it.
Future<bool> handleDecommissionedBackgroundTask(String task) async => true;

/// Top-level callback for WorkManager. Runs in a background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) => handleDecommissionedBackgroundTask(task),
  );
}
