/// Interactor to request health data permissions from the platform.
/// Returns true if all required permissions were granted.
abstract class RequestHealthPermissionsInteractor {
  Future<bool> execute();
}
