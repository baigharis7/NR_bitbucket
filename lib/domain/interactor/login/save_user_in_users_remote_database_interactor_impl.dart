import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';

class SaveUserInUsersRemoteDatabaseInteractorImpl extends SaveUserInUsersRemoteDatabaseInteractor {
  final LoginRepository loginRepository;

  SaveUserInUsersRemoteDatabaseInteractorImpl({required this.loginRepository});

  @override
  Future<void> execute(SimpleUser simpleUser) => loginRepository.saveUserInUsersRemoteDatabase(simpleUser);

}