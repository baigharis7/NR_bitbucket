import '../../../data/local/models/modelsappearence/models_appearance_entity.dart';

abstract class ModelsAppearanceRepository {
  Future<ModelsAppearanceEntity?> showModelAppearance(int modelAppearanceId);
  Future<void> saveModelAppearance(int modelAppearanceId);
}