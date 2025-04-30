import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/show_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/modelsappearance/models_appearance_repository.dart';

class ShowModelAppearanceInteractorImpl extends ShowModelAppearanceInteractor {
  final ModelsAppearanceRepository modelsAppearanceRepository;

  ShowModelAppearanceInteractorImpl({required this.modelsAppearanceRepository});
  @override
  Future<bool> execute(int modelAppearanceId) async => modelsAppearanceRepository.showModelAppearance(modelAppearanceId);
  
}