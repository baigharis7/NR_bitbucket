abstract class EventsSynchronizationRequestRepository {
  Future<bool> synchronizeEvents(String userId, {required bool fullSync});
  Future<bool> fetchEvents(String userId, String categoryType, {required bool fullSync});
}
