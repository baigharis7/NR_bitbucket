import 'package:amplify_flutter/amplify_flutter.dart';
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