import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';

class SignInInteractorImpl extends SignInInteractor{
  final LoginRepository loginRepository;

  SignInInteractorImpl({required this.loginRepository});

  @override
  Future<SignInResult> execute(String username, String password) => loginRepository.signIn(username, password);
}