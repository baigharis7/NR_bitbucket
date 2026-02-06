/// Interactor to check the status of health data sync.
/// Returns true if health sync is available, enabled, and has permissions.
abstract class CheckHealthSyncStatusInteractor {
  Future<bool> execute();
}
