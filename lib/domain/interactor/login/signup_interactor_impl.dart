import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';

import '../../repository/login/login_repository.dart';

class SignUpInteractorImpl extends SignUpInteractor {
  final LoginRepository loginRepository;

  SignUpInteractorImpl({required this.loginRepository});

  @override
  Future<SignUpResult> execute(String username, String email, String password) => loginRepository.signUp(username, email, password);

}