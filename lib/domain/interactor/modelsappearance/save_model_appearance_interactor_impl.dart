import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/save_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/modelsappearance/models_appearance_repository.dart';

class SaveModelAppearanceInteractorImpl extends SaveModelAppearanceInteractor {
  final ModelsAppearanceRepository modelsAppearanceRepository;
  SaveModelAppearanceInteractorImpl({required this.modelsAppearanceRepository});
  @override
  Future<void> execute(int modelAppearanceId) async => modelsAppearanceRepository.saveModelAppearance(modelAppearanceId);

}