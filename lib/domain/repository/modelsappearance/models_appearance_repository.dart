abstract class ModelsAppearanceRepository {
  Future<bool> showModelAppearance(int modelAppearanceId);
  Future<void> saveModelAppearance(int modelAppearanceId);
}