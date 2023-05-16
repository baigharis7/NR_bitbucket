import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';

class ResendVerificationCodeInteractorImpl extends ResendVerificationCodeInteractor {
  final LoginRepository loginRepository;

  ResendVerificationCodeInteractorImpl({required this.loginRepository});

  @override
  Future<void> execute(String username) => loginRepository.resendVerificationCode(username);

}