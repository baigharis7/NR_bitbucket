import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
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
  final GetMasterFileVersionInteractor getMasterFilesVersionInteractor;
  final ManageMasterFilesInteractor manageMasterFilesInteractor;
  final SaveMasterFileInteractor saveMasterFileInteractor;
  final CheckProfileExistenceInteractor checkProfileExistenceInteractor;
  final DownloadProfileInteractor downloadProfileInteractor;
  final GetIdTokenInteractor getIdTokenInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final ResendVerificationCodeInteractor resendVerificationCodeInteractor;
  final SaveUserCredentialsInteractor saveUserCredentialsInteractor;
  final SaveUserInUsersRemoteDatabaseInteractor saveUserInUsersRemoteDatabaseInteractor;
  final SignOutInteractor signOutInteractor;

  LoginProvider({
    required this.signUpInteractor,
    required this.verificationCodeInteractor,
    required this.fetchUserAttributesInteractor,
    required this.signInInteractor,
    required this.saveUsernameAndEmailInteractor,
    required this.getMasterFilesVersionInteractor,
    required this.manageMasterFilesInteractor,
    required this.saveMasterFileInteractor,
    required this.checkProfileExistenceInteractor,
    required this.downloadProfileInteractor,
    required this.getIdTokenInteractor,
    required this.saveProfileInteractor,
    required this.resendVerificationCodeInteractor,
    required this.saveUserCredentialsInteractor,
    required this.saveUserInUsersRemoteDatabaseInteractor,
    required this.signOutInteractor,
  });

  get getNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;
  get isLogin => _loginMode;
  get getEmail => _email.orEmpty();
  get getUsername => _username.orEmpty();
  get getPassword => _password.orEmpty();
  get isLoginMode => _loginMode;
  get areMasterFilesChecked => _masterFilesChecked;
  get isProfileChecked => _profileChecked;
  get goToRegistry => _goToRegistry;
  get isNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;

  String? _email;
  String? _username;
  String? _password;
  bool _loginMode = true;
  bool _masterFilesChecked = false;
  bool _profileChecked = false;
  Function? _goToRegistry;
  bool _notConfirmedUserTryingToLogin = false;
  bool _userNameAlreadyUsed = false;

  void changeLoginMode(Function action) {
    _setLoginMode(!isLogin);
    notifyListeners();
    if (!isLogin) {
      action.call();
    }
  }

  void submitData({
    required String username,
    required String email,
    required String password,
    required String repeatPassword,
    required Function action,
    required Function goToRegistry,
  }) async {
    _setEmail(email.orEmpty());
    _setUserName(username.orEmpty());
    _setPassword(password.orEmpty());
    _setGoToRegistry(goToRegistry);

    if (getUsername.isEmptyOrNull()) {
      // TODO: manage error.
      // Error: campo vacío.
    } else if (getPassword.isEmptyOrNull()) {
      // TODO: manage error.
      // Error: campo vacío.
    } else if (!isLogin && repeatPassword.isEmptyOrNull()) {
      // TODO: manage error.
      // Error campo vacío.
    } else if (!isLogin && getEmail.isEmptyOrNull()) {
      // TODO: manage error.
      // Error campo vacío.
    } else {
      if (isLogin) {
        _fetchUserAttributes(action, isFromLogin: true);
      } else {
        if (password != repeatPassword) {
          // TODO: manage error.

        } else {
          launchSync(
              block: () => signUpInteractor.execute(
                getUsername,
                getEmail,
                getPassword,
              ),
              onSuccess: (result) => _onSignUpSuccess(result, action),
              onError: (error) => _onSignUpError(error));
        }
      }
    }
  }

  void notConfirmedUserAsksForNewVerificationCode(Function showMfaDialog) {
    _setNotConfirmedUserTryingToLogin(false);

    launchSync(
      block: () => resendVerificationCodeInteractor.execute(getUsername.orEmpty()),
      onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) => showMfaDialog.call(),
      onError: (error) {
        // TODO: manage errors.
      },
    );
  }

  void notConfirmedUserCancelsReceiveConfirmationCode() {
    _setNotConfirmedUserTryingToLogin(false);
    notifyListeners();
  }

  void _setLoginMode(bool isLogin) => _loginMode = isLogin;
  void _setEmail(String email) => _email = email;
  void _setUserName(String username) => _username = username;
  void _setPassword(String password) => _password = password;
  void _setGoToRegistry(Function goToRegistry) => _goToRegistry = goToRegistry;
  void _setMasterFilesChecked(bool masterFilesChecked) => _masterFilesChecked = masterFilesChecked;
  void _setProfileChecked(bool profileChecked) => _profileChecked = profileChecked;
  void _setNotConfirmedUserTryingToLogin(bool notConfirmedUserTryingToLogin) => _notConfirmedUserTryingToLogin = notConfirmedUserTryingToLogin;


  void _onSignInError(Object error) {
    if (error is UserNotConfirmedException) {
      _setNotConfirmedUserTryingToLogin(true);
    } else if (error is NotAuthorizedException) {
      // Username/email o password incorrectos o no existen.
      // TODO: manage errors.
      const g = '';
    }
  }

  void _fetchUserAttributes(Function moveToNextScreen, {bool isFromVerificationCode = false, bool isFromLogin = false}) async {
    if (isFromLogin) await signOutInteractor.execute();

    launchSync(
        block: () => fetchUserAttributesInteractor.execute(),
        onSuccess: (CognitoAuthSession session) async {
          if (!isUserConfirmedFromToken(session.userPoolTokens?.idToken)) {
            _setNotConfirmedUserTryingToLogin(true);
          } else if (isFromVerificationCode) {
            _saveUserInRemoteUsersDatabase(session.userSub.orEmpty(), () {
              _onFetchUserAttributesSuccess(session, moveToNextScreen);
            });
          } else {
            _onFetchUserAttributesSuccess(session, moveToNextScreen);
          }
        },
        onError: (error) => _onFetchUserAttributesError(error, moveToNextScreen));
  }

  void _onSignUpSuccess(SignUpResult result, Function action) {
    _saveUsernameAndEmail(getUsername, getEmail);
    action.call();
  }

  void _onSignUpError(Object error) {
    // TODO: manage error.
    if (error is UsernameExistsException) {
      // TODO: enseñar cartel de que tiene que usar otro nombre
      const h = '';
    }
  }

  void sendVerificationCode(String confirmationCode, Function action) {
    launchSync(
      block: () => verificationCodeInteractor.execute(confirmationCode, getUsername),
      onSuccess: (signUpResult) => _onSendVerificationCodeSuccess(signUpResult, action),
      onError: (error) => _onSendVerificationCodeError(error),
    );
  }

  void _onSendVerificationCodeSuccess(SignUpResult signUpResult, Function action) {
    _fetchUserAttributes(action, isFromVerificationCode: true);
  }

  void _onSendVerificationCodeError(Object error) {
    // TODO: manage errors.
    const g = '';
  }

  void _onFetchUserAttributesSuccess(CognitoAuthSession session, Function moveToNextScreen) {
    launchSync(
        block: () => saveUserCredentialsInteractor.execute(session),
        onSuccess: (_) {
          if (session.isSignedIn) {
            if (!isProfileChecked) {
              launchSync(
                  block: () => checkProfileExistenceInteractor.execute(),
                  onSuccess: (profileExists) {
                    _setProfileChecked(true);
                    if (!profileExists) {
                      String? email = getEmailFromToken(getIdTokenInteractor.execute());
                      if (email.isNotNull()) {
                        downloadProfile(email.orEmpty(), moveToNextScreen);
                      } else {
                        // TODO: manage errors.
                        const g = '';
                      }
                    } else {
                      _manageMasterFiles(moveToNextScreen);
                    }
                  },
                  onError: (error) {
                    // TODO: manage errors.
                    const g = '';
                  });
            } else {
              if (!areMasterFilesChecked) {
                _manageMasterFiles(moveToNextScreen);
              } else {
                moveToNextScreen.call();
              }
            }
          } else {
            _performSignIn(getUsername.orEmpty(), getPassword.orEmpty(), moveToNextScreen);
          }
        },
        onError: (error) {
          // TODO: manage errors.
          const g = '';
        });
  }

  void _onFetchUserAttributesError(Object error, Function action) {
    if (error is UserNotConfirmedException) {
      _setNotConfirmedUserTryingToLogin(true);
    } else if (error is SignedOutException) {
      _performSignIn(getUsername, getPassword, action);
    } else {
      // TODO: manage errors.
      const g = '';
    }
  }

  void downloadProfile(String email, Function? moveToNextScreen) {
    launchSync(
      block: () => downloadProfileInteractor.execute(email.orEmpty()),
      onSuccess: (UserProfileModel? userProfileModel) {
        if (userProfileModel.isNull()) {
          // TODO: poner diálogo que avisa de que no tiene perfil y tiene que tenerlo para usar la app.
          _manageMasterFiles(() => _goToRegistry?.call());
        } else {
          _saveProfileInLocal(userProfileModel!, moveToNextScreen!);
        }
      },
      onError: (error) {
        // TODO: manage errors.
        const g = '';
        _setProfileChecked(false);
      },
    );
  }

  void _saveProfileInLocal(UserProfileModel userProfileModel, Function? moveToNextScreen) {
    launchSync(
      block: () => saveProfileInteractor.execute(userProfileModel),
      onSuccess: (_) => _manageMasterFiles(moveToNextScreen),
      onError: (error) {
        // TODO: manage errors.
        const g = '';
        _setProfileChecked(false);
      },
    );
  }

  void _saveUsernameAndEmail(String username, String email) {
    saveUsernameAndEmailInteractor.execute(username, email);
  }

  void resendVerificationCode() {
    launchSync(
      block: () => resendVerificationCodeInteractor.execute(_username.orEmpty()),
      onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) {
        // TODO: poner toast.
        const g = '';
      },
      onError: (error) {
        // TODO: manage errors.
        const g = '';
      },
    );
  }

  void _performSignIn(String username, String password, Function action) {
    launchSync(
        block: () => signInInteractor.execute(
              username.orEmpty(),
              password.orEmpty(),
            ),
        onSuccess: (SignInResult result) => _fetchUserAttributes(action),
        onError: (error) => _onSignInError(error));
  }

  void _manageMasterFiles(Function? onFinish) {
    launchSync(
        block: () async => manageMasterFilesInteractor.execute(
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.cookingMethods),
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.cookingMethodsInfo),
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.foodsAndDrinksNames),
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.nutrientsInfo),
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.objectivesInfo),
              await getMasterFilesVersionInteractor
                  .execute(MasterFilesType.recommendationGroups),
            ),
        onSuccess: (MasterFilesResponse masterFilesResponse) => _onSuccessManageMasterFiles(masterFilesResponse, onFinish),
        onError: (error) => _onErrorManageMasterFiles(error, onFinish));
  }

  void _onSuccessManageMasterFiles(MasterFilesResponse masterFilesResponse, Function? onFinish) {
    masterFilesResponse.cookingMethodsResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsResponse,
          MasterFilesType.cookingMethods);
    });
    masterFilesResponse.cookingMethodsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsInfoResponse,
          MasterFilesType.cookingMethodsInfo);
    });
    masterFilesResponse.foodsAndDrinksNamesResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.foodsAndDrinksNamesResponse,
          MasterFilesType.foodsAndDrinksNames);
    });
    masterFilesResponse.nutrientsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.nutrientsInfoResponse,
          MasterFilesType.nutrientsInfo);
    });
    masterFilesResponse.objectivesResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(masterFilesResponse.objectivesResponse,
          MasterFilesType.objectivesInfo);
    });
    masterFilesResponse.recommendationGroupsResponse.doIfAintNull(() {
      saveMasterFileInteractor.execute(
          masterFilesResponse.recommendationGroupsResponse,
          MasterFilesType.recommendationGroups);
    });
    _setMasterFilesChecked(true);
    onFinish?.call();
  }

  void _onErrorManageMasterFiles(Object error, Function? onFinish) {
    // TODO: manage errors.
    _setMasterFilesChecked(false);
    // onFinish?.call();
  }

  void _saveUserInRemoteUsersDatabase(String userId, Function finishFetchUserAttributes) {
    final simpleUser = SimpleUser(
        email: getEmail.orEmpty(), userName: getUsername.orEmpty(), userId: userId);
    launchSync(
        block: () => saveUserInUsersRemoteDatabaseInteractor.execute(simpleUser),
        onSuccess: (_) => finishFetchUserAttributes.call(),
        onError: (error) {
          // TODO: manage errors.
          const g = '';
        },
    );
  }
}
