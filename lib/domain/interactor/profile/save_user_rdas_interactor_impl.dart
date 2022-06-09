import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class SaveUserRdasInteractorImpl extends SaveUserRdasInteractor {
  final LocalStorageRepository localStorageRepository;

  SaveUserRdasInteractorImpl({required this.localStorageRepository});

  @override
  Future<void> execute(List<UserRdasResponse> userRdas) async => await localStorageRepository.saveUserRdas(userRdas);

}