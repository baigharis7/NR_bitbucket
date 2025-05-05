import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/modelsappearance/models_appearance_repository.dart';

import '../../local/models/modelsappearence/models_appearance_entity.dart';

class ModelsAppearanceRepositoryImpl extends ModelsAppearanceRepository {
  final LocalStorageRepository localStorageRepository;
  ModelsAppearanceRepositoryImpl({required this.localStorageRepository});
  @override
  Future<ModelsAppearanceEntity?> showModelAppearance(int modelAppearanceId) async => localStorageRepository.showModelAppearance(modelAppearanceId);

  @override
  Future<void> saveModelAppearance(int modelAppearanceId) => localStorageRepository.saveModelAppearance(modelAppearanceId);

}