abstract class UpdateEventsInteractor {
  Future<bool> execute({required String userId, required String categoryType, required bool fullSync});
}