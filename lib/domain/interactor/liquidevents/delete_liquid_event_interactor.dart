abstract class DeleteLiquidEventInteractor {
  Future<void> execute(String userId, int eventDate);
}