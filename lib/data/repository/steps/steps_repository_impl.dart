import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class StepsRepositoryImpl extends StepsRepository {
  final StepsApi stepsApi;
  final LocalStorageRepository localStorageRepository;

  StepsRepositoryImpl({required this.stepsApi, required this.localStorageRepository});

  @override
  Future<void> uploadSteps() => stepsApi.uploadSteps();

  @override
  Future<void> saveSteps() {
    // TODO: implement saveSteps
    throw UnimplementedError();
  }

}