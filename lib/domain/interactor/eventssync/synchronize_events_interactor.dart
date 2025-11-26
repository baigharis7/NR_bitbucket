abstract class SynchronizeEventsInteractor {
  Future<void> execute(String userId, {required bool fullSync});
}