/// Interactor to enable or disable health data sync.
/// When enabled, also registers background sync task.
/// When disabled, cancels background sync task.
/// Returns true if the operation was successful.
abstract class ToggleHealthSyncInteractor {
  Future<bool> execute(bool enable);
}
