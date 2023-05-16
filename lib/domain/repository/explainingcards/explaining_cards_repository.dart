abstract class ExplainingCardsRepository {
  Future<void> saveExplainingCardInteraction(int explainingCardId);
  Future<bool> isNecessaryToShowExplainingCard(int explainingCardId);
}