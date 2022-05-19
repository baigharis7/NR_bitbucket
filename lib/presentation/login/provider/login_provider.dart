import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

// TODO: manage errors, finish flows, sort functions and variables.
class LoginProvider extends BaseProvider {
  final SignUpInteractor signUpInteractor;
  final SendVerificationCodeInteractor verificationCodeInteractor;
  final FetchUserAttributesInteractor fetchUserAttributesInteractor;
  final SignInInteractor signInInteractor;
  final SaveUsernameAndEmailInteractor saveUsernameAndEmailInteractor;
  final IsUserSignedInInteractor isUserSignedInInteractor;

  LoginProvider({
    required this.signUpInteractor,
    required this.verificationCodeInteractor,
    required this.fetchUserAttributesInteractor,
    required this.signInInteractor,
    required this.saveUsernameAndEmailInteractor,
    required this.isUserSignedInInteractor
  });

  String? email;
  String? username;
  String? password;
  bool isLogin = true;

  init() async {
    await _refreshAllStates();
  }

  _refreshAllStates() async {
    notifyListeners();
  }

  void changeLoginMode(Function action) {
    isLogin = !isLogin;
    notifyListeners();
    if (!isLogin) {
      action.call();
    }
  }

  void submitData({
    String? username,
    String? email,
    String? password,
    String? repeatPassword,
    Function? action,
  }) async {
    this.email = email.orEmpty();
    this.username = username.orEmpty();
    this.password = password.orEmpty();

    if (this.username.isEmptyOrNull()) {
      // Error: campo vacío.
    } else if (this.password.isEmptyOrNull()) {
      // Error: campo vacío.
    } else if (!isLogin && repeatPassword.isEmptyOrNull()) {
      // Error campo vacío.
    } else if (!isLogin && this.email.isEmptyOrNull()) {
      // Error campo vacío.
    } else {
      if (isLogin) {
        fetchUserAttributes(action!);
        // performSignIn(username.orEmpty(), password.orEmpty(), action!);
        // Comprobación de perfil y masterfiles files.

      } else {
        if (password != repeatPassword) {
          // TODO: manage error.

        } else {
          launchSync(
              block: () => signUpInteractor.execute(
                this.username.orEmpty(),
                this.email.orEmpty(),
                this.password.orEmpty(),
              ),
              onSuccess: (result) => onSignUpSuccess(result, action!),
              onError: (Object error) => onSignUpError(error)
          );
        }
      }
    }
  }

  void onSignInError(Object error) {
    const g = '';
  }

  void fetchUserAttributes(Function? moveToNextScreen) {
    launchSync(
        block: () => fetchUserAttributesInteractor.execute(),
        onSuccess: (_) => onFetchUserAttributesSuccess(moveToNextScreen),
        onError: (error) => onFetchUserAttributesError(error, moveToNextScreen)
    );
  }

  void onSignUpSuccess(SignUpResult result, Function action) {
    saveUsernameAndEmail(username.orEmpty(), email.orEmpty());
    action.call();
  }

  void onSignUpError(Object error) {
    // TODO: manage error.
  }

  void sendVerificationCode(String confirmationCode, Function action) {
    launchSync(
        block: () => verificationCodeInteractor.execute(confirmationCode, username.orEmpty()),
        onSuccess: (signUpResult) => onSendVerificationCodeSuccess(signUpResult, action),
        onError: (error) => onSendVerificationCodeError(error),
    );
  }

  void onSendVerificationCodeSuccess(SignUpResult signUpResult, action) {
    fetchUserAttributes(action);
  }

  void onSendVerificationCodeError(Object error) {
    const g = '';
  }

  void onFetchUserAttributesSuccess(Function? moveToNextScreen) {
    launchSync(
      block: () => isUserSignedInInteractor.execute(),
        onSuccess: (isSignedIn) => {
          if (isSignedIn) {
            moveToNextScreen?.call()
          } else {
            performSignIn(username.orEmpty(), password.orEmpty(), moveToNextScreen)
          }
      },
        onError: (error) {
          performSignIn(username.orEmpty(), password.orEmpty(), moveToNextScreen);
        },
    );
  }

  void onFetchUserAttributesError(Object error, Function? action) {
    performSignIn(username.orEmpty(), password.orEmpty(), action);
  }

  void saveUsernameAndEmail(String username, String email) {
    saveUsernameAndEmailInteractor.execute(username, email);
  }

  void resendVerificationCode(String username, Function onResendSuccess, Function onResendError) {
    // loginInteractor.resendVerificationCode('zosdam@gmail.com', onResendSuccess, onResendError);
  }

  void performSignIn(String username, String password, Function? action) {
    launchSync(
        block: () => signInInteractor.execute(
          username.orEmpty(),
          password.orEmpty(),
        ),
        onSuccess: (SignInResult result) {
          fetchUserAttributes(action);
          action?.call();
        },
        onError: (error) => onSignInError(error)
    );
  }

}
