import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/modelsappearance/models_appearance_repository.dart';

class ModelsAppearanceRepositoryImpl extends ModelsAppearanceRepository {
  final LocalStorageRepository localStorageRepository;
  ModelsAppearanceRepositoryImpl({required this.localStorageRepository});
  @override
  Future<bool> showModelAppearance(int modelAppearanceId) async => localStorageRepository.showModelAppearance(modelAppearanceId);

  @override
  Future<void> saveModelAppearance(int modelAppearanceId) => localStorageRepository.saveModelAppearance(modelAppearanceId);

}