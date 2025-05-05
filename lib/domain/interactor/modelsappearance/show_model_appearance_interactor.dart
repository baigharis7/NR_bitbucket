import '../../../data/local/models/modelsappearence/models_appearance_entity.dart';

abstract class ShowModelAppearanceInteractor {
  Future<ModelsAppearanceEntity?> execute(int modelAppearanceId);
}