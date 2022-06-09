import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';

class GetUserRdasInteractorImpl extends GetUserRdasInteractor {
  final LocalStorageRepository localStorageRepository;

  GetUserRdasInteractorImpl({required this.localStorageRepository});

  @override
  Future<List<UserRdas>> execute() => localStorageRepository.getUserRdas();

}