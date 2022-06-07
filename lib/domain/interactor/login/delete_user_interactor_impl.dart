import 'package:nutrenaissance_flutter/domain/interactor/login/delete_user_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';

class DeleteUserInteractorImpl extends DeleteUserInteractor {
  final LoginRepository loginRepository;

  DeleteUserInteractorImpl({required this.loginRepository});

  @override
  Future<void> execute() => loginRepository.deleteUser();

}