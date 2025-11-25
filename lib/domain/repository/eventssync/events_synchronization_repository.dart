abstract class EventsSynchronizationRequestRepository {
  Future<bool> synchronizeEvents(String userId, {bool fullSync = false});
  Future<bool> fetchEvents(String userId, String categoryType);
}
