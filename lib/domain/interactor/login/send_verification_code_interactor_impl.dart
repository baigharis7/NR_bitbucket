import 'package:amplify_auth_plugin_interface/src/SignUp/SignUpResult.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';

class SendVerificationCodeInteractorImpl extends SendVerificationCodeInteractor {
  final LoginRepository loginRepository;

  SendVerificationCodeInteractorImpl({required this.loginRepository});

  @override
  Future<SignUpResult> execute(String confirmationCode, String username) {
    return loginRepository.sendVerificationCode(confirmationCode, username);
  }

}