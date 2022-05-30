import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

// TODO: manage errors, finish flows, sort functions and variables.
class LoginProvider extends BaseProvider {
  final SignUpInteractor signUpInteractor;
  final SendVerificationCodeInteractor verificationCodeInteractor;
  final FetchUserAttributesInteractor fetchUserAttributesInteractor;
  final SignInInteractor signInInteractor;
  final SaveUsernameAndEmailInteractor saveUsernameAndEmailInteractor;
  final IsUserSignedInInteractor isUserSignedInInteractor;
  final GetMasterFileVersionInteractor getMasterFilesVersionInteractor;
  final ManageMasterFilesInteractor manageMasterFilesInteractor;
  final SaveMasterFileInteractor saveMasterFileInteractor;
  final CheckProfileExistenceInteractor checkProfileExistenceInteractor;
  final DownloadProfileInteractor downloadProfileInteractor;
  final GetIdTokenInteractor getIdTokenInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final ResendVerificationCodeInteractor resendVerificationCodeInteractor;
  final SaveUserInUsersRemoteDatabaseInteractor
      saveUserInUsersRemoteDatabaseInteractor;

  LoginProvider({
    required this.signUpInteractor,
    required this.verificationCodeInteractor,
    required this.fetchUserAttributesInteractor,
    required this.signInInteractor,
    required this.saveUsernameAndEmailInteractor,
    required this.isUserSignedInInteractor,
    required this.getMasterFilesVersionInteractor,
    required this.manageMasterFilesInteractor,
    required this.saveMasterFileInteractor,
    required this.checkProfileExistenceInteractor,
    required this.downloadProfileInteractor,
    required this.getIdTokenInteractor,
    required this.saveProfileInteractor,
    required this.resendVerificationCodeInteractor,
    required this.saveUserInUsersRemoteDatabaseInteractor,
  });

  String? _email;
  String? _username;
  String? _password;
  bool isLogin = true;
  bool _areMasterFilesChecked = false;
  bool _isProfileChecked = false;
  Function? _goToRegistry;

  // init() async {
  //   await _refreshAllStates();
  // }

  // _refreshAllStates() async {
  //   notifyListeners();
  // }

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
    Function? goToRegistry,
  }) async {
    _email = email.orEmpty();
    _username = username.orEmpty();
    _password = password.orEmpty();
    _goToRegistry = goToRegistry;

    if (_username.isEmptyOrNull()) {
      // Error: campo vacío.
    } else if (_password.isEmptyOrNull()) {
      // Error: campo vacío.
    } else if (!isLogin && repeatPassword.isEmptyOrNull()) {
      // Error campo vacío.
    } else if (!isLogin && _email.isEmptyOrNull()) {
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
                _username.orEmpty(),
                _email.orEmpty(),
                _password.orEmpty(),
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

    launchSync(
    );
  }

  void fetchUserAttributes(Function? moveToNextScreen, {bool isFromVerificationCode = false, bool isFromLogin = false}) async {

    if (isFromLogin) await signOutInteractor.execute();

    launchSync(
        block: () => fetchUserAttributesInteractor.execute(),
        onSuccess: (CognitoAuthSession session) async {
          } else if (isFromVerificationCode) {
            saveUserInRemoteUsersDatabase(session.userSub.orEmpty(), () {
              onFetchUserAttributesSuccess(session, moveToNextScreen);
            });
          } else {
            onFetchUserAttributesSuccess(session, moveToNextScreen);
          }
        },
        onError: (error) =>
            onFetchUserAttributesError(error, moveToNextScreen));
  }

  void onSignUpSuccess(SignUpResult result, Function action) {
    saveUsernameAndEmail(_username.orEmpty(), _email.orEmpty());
    action.call();
  }

  void onSignUpError(Object error) {
    // TODO: manage error.
  }

  void sendVerificationCode(String confirmationCode, Function action) {
    launchSync(
        block: () => verificationCodeInteractor.execute(confirmationCode, _username.orEmpty()),
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
        onSuccess: (isSignedIn) {
          if (isSignedIn) {
            if (!_isProfileChecked) {
              launchSync(
                  block: () => checkProfileExistenceInteractor.execute(),
                  onSuccess: (profileExists) {
                    _isProfileChecked = true;
                    if (!profileExists) {
                      String? email = getEmailFromToken(getIdTokenInteractor.execute());
                      launchSync(
                        block: () => downloadProfileInteractor.execute(email.orEmpty()),
                        onSuccess: (UserProfileModel? userProfileModel) {
                          if (userProfileModel.isNull()) {
                            // TODO: si no tiene perfil en AWS es una movida. Llevarlo a la pantalla de creación de perfil.
                            // TODO: Mostrar diálogo que avisa de la situación y lleva a la pantalla de registro.
                            _goToRegistry?.call();
                          } else {
                            launchSync(
                              block: () => saveProfileInteractor.execute(userProfileModel!),
                              onSuccess: (_) {
                                manageMasterFiles(moveToNextScreen);
                              },
                              onError: () {
                                // TODO: manage errors.
                                const g = '';
                                _isProfileChecked = false;
                                },
                            );
                          }
                          },
                        onError: (error) {
                          // TODO: manage errors.
                          const g = '';
                          _isProfileChecked = false;
                        },
                      );
                    } else {
                      manageMasterFiles(moveToNextScreen);
                    }
                },
                  onError: (error) {
                    // TODO: manage errors.
                    const g = '';
                  }
              );
            } else {
              if (!_areMasterFilesChecked) {
                manageMasterFiles(moveToNextScreen);
              } else {
                moveToNextScreen?.call();
              }
            }
          } else {
            performSignIn(_username.orEmpty(), _password.orEmpty(), moveToNextScreen);
          }
      },
        onError: (error) {
          performSignIn(_username.orEmpty(), _password.orEmpty(), moveToNextScreen);
        },
    );
  }

  void onFetchUserAttributesError(Object error, Function? action) {
    performSignIn(_username.orEmpty(), _password.orEmpty(), action);
  }

  void saveUsernameAndEmail(String username, String email) {
    saveUsernameAndEmailInteractor.execute(username, email);
  }

  void resendVerificationCode() {
    launchSync(
        block: () => resendVerificationCodeInteractor.execute(_username.orEmpty()),
        onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) {
          // TODO: poner toast.
        },
        onError: (Object error) {
          // TODO: manage errors.
        },
    );
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

  void manageMasterFiles(Function? onFinish) {
    launchSync(
        block: () async => manageMasterFilesInteractor.execute(
          await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethods),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethodsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.foodsAndDrinksNames),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.nutrientsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.objectivesInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.recommendationGroups),
        ),
        onSuccess: (MasterFilesResponse masterFilesResponse) => onSuccessManageMasterFiles(masterFilesResponse, onFinish),
        onError: (Object error) => onErrorManageMasterFiles(error, onFinish)
    );
  }

  void onSuccessManageMasterFiles(MasterFilesResponse masterFilesResponse, Function? onFinish) {
    masterFilesResponse.cookingMethodsResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsResponse,
          MasterFilesType.cookingMethods
      );
    });
    masterFilesResponse.cookingMethodsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsInfoResponse,
          MasterFilesType.cookingMethodsInfo
      );
    });
    masterFilesResponse.foodsAndDrinksNamesResponse.doIfAintNull((){
      saveMasterFileInteractor.execute(
        masterFilesResponse.foodsAndDrinksNamesResponse,
        MasterFilesType.foodsAndDrinksNames
      );
    });
    masterFilesResponse.nutrientsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.nutrientsInfoResponse,
          MasterFilesType.nutrientsInfo
      );
    });
    masterFilesResponse.objectivesResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.objectivesResponse,
          MasterFilesType.objectivesInfo
      );
    });
    masterFilesResponse.recommendationGroupsResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.recommendationGroupsResponse,
          MasterFilesType.recommendationGroups
      );
    });
    _areMasterFilesChecked = true;
    onFinish?.call();
  }

  void onErrorManageMasterFiles(Object error, Function? onFinish) {
    // TODO: manage error.
    _areMasterFilesChecked = true;
    onFinish?.call();
  }

  void saveUserInRemoteUsersDatabase(
      String userId, Function finishFetchUserAttributes) {
    final simpleUser = SimpleUser(
        email: _email.orEmpty(), userName: _username.orEmpty(), userId: userId);
    launchSync(
        block: () =>
            saveUserInUsersRemoteDatabaseInteractor.execute(simpleUser),
        onSuccess: (_) {
          finishFetchUserAttributes.call();
        },
        onError: () {
          // TODO: manage errors.
          const g = '';
        });
  }
}
