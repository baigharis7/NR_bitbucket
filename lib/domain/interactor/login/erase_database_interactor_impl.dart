import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';

class EraseDatabaseInteractorImpl extends EraseDatabaseInteractor {
  final LocalStorageRepository localStorageRepository;

  EraseDatabaseInteractorImpl({required this.localStorageRepository});

  @override
  Future<bool> execute() async => await localStorageRepository.eraseDatabaseInformation();

}