import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
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
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/validator_utils.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/login/bloc/login_actions.dart';
import 'package:nutrenaissance_flutter/presentation/login/bloc/login_state.dart';

class LoginBloc extends BaseBloc<LoginActions, LoginState> {
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

  LoginBloc({
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
  }) : super(LoginState(isLoading: false)) {

    on<InitialiseBlocAction>((event, emit) {
      emit(LoginState(
        isLoading: false,
        username: state.username.orEmpty(),
        email: state.email.orEmpty(),
        password: state.password.orEmpty(),
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);
    });

    on<SendVerificationCodeAction>((event, emit) async {
      emit(LoginState(isLoading: true, goToRegistry: state.goToRegistry));
      launchSync(
        block: () async => await verificationCodeInteractor.execute(event.confirmationCode, state.username.orEmpty()),
        onSuccess: (signUpResult) async {
          _onSendVerificationCodeSuccess(signUpResult, event.onSuccess, () {
            emit(LoginState(
              isLoading: false,
              username: state.username.orEmpty(),
              email: state.email.orEmpty(),
              password: state.password.orEmpty(),
              goToRegistry: state.goToRegistry,
              areMasterFilesChecked: state.areMasterFilesChecked,
              isLogin: state.isLogin,
              isPasswordVisible: state.isPasswordVisible,
              isProfileChecked: state.isProfileChecked,
              notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
            ),);
          });
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
        },
        onError: (error) {
          _onSendVerificationCodeError(error);
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
        },
      );
    });

    on<ResendVerificationCodeAction>((event, emit) async {
      emit(LoginState(isLoading: true, goToRegistry: state.goToRegistry));

      launchSync(
        block: () async => await resendVerificationCodeInteractor.execute(state.username.orEmpty()),
        onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) {
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
        },
        onError: (error) {
          state.errorTypes = ErrorTypes.resendVerificationCodeError;
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
        },
      );
    });

    on<UnconfirmedUserCancelsConfirmationCodeReceptionAction>((event, emit) async {
      // TODO: WTF??
      emit(LoginState(
        isLoading: false,
        username: state.username.orEmpty(),
        email: state.email.orEmpty(),
        password: state.password.orEmpty(),
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);
    });

    on<UnconfirmedUserAsksForNewVerificationCodeAction>((event, emit) {
      state.notConfirmedUserTryingToLogin = false;
      emit(LoginState(
        isLoading: true,
        username: state.username.orEmpty(),
        email: state.email.orEmpty(),
        password: state.password.orEmpty(),
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);

      launchSync(
        block: () async => await resendVerificationCodeInteractor.execute(state.username.orEmpty()),
        onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) async {
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
          event.showMfaDialog?.call();
        },
        onError: (error) {
          state.errorTypes = ErrorTypes.resendVerificationCodeError;
          emit(LoginState(
            isLoading: false,
            username: state.username.orEmpty(),
            email: state.email.orEmpty(),
            password: state.password.orEmpty(),
            goToRegistry: state.goToRegistry,
            areMasterFilesChecked: state.areMasterFilesChecked,
            isLogin: state.isLogin,
            isPasswordVisible: state.isPasswordVisible,
            isProfileChecked: state.isProfileChecked,
            notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
          ),);
        },
      );
    });

    on<LaunchLoginAction>((event, emit) async {
      emit(LoginState(
        isLoading: true,
        username: event.username.orEmpty(),
        email: event.email.orEmpty(),
        password: event.password.orEmpty(),
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);

      if (state.isLogin) {
        await _fetchUserAttributes(event.action!, isFromLogin: true, removeLoading: () {},);

      } else {
        if (state.password != event.repeatPassword) {
          state.errorTypes = ErrorTypes.passwordsNotMatchingError;
          if (emit.isDone) {
            emit(
              LoginState(
                isLoading: false,
                username: state.username,
                email: state.email,
                password: state.password,
                goToRegistry: state.goToRegistry,
                areMasterFilesChecked: state.areMasterFilesChecked,
                isLogin: state.isLogin,
                isPasswordVisible: state.isPasswordVisible,
                isProfileChecked: state.isProfileChecked,
                notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
              ),
            );
          }
        } else {
          launchSync(
              block: () async => await signUpInteractor.execute(
                state.username.orEmpty(),
                state.email.orEmpty(),
                state.password.orEmpty(),
              ),
              onSuccess: (result) {
                _onSignUpSuccess(result, event.action!, () {
                  emit(LoginState(
                    isLoading: false,
                    username: state.username,
                    email: state.email,
                    password: state.password,
                    goToRegistry: state.goToRegistry,
                    areMasterFilesChecked: state.areMasterFilesChecked,
                    isLogin: state.isLogin,
                    isPasswordVisible: state.isPasswordVisible,
                    isProfileChecked: state.isProfileChecked,
                    notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
                  ),);
                });
              },
              onError: (error) {
                _onSignUpError(error);
                emit(LoginState(
                  isLoading: false,
                  username: state.username,
                  email: state.email,
                  password: state.password,
                  goToRegistry: state.goToRegistry,
                  areMasterFilesChecked: state.areMasterFilesChecked,
                  isLogin: state.isLogin,
                  isPasswordVisible: state.isPasswordVisible,
                  isProfileChecked: state.isProfileChecked,
                  notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
                ),);
              },
          );
        }
      }
    });

    on<ChangePasswordVisibilityAction>((event, emit) {
      _changePasswordVisibility();
      emit(LoginState(
        isLoading: false,
        username: state.username,
        email: state.email,
        password: state.password,
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);
    });

    on<ChangeLoginModeAction>((event, emit) {
      _changeLoginMode(event.action);
      emit(LoginState(
        isLoading: false,
        username: state.username,
        email: state.email,
        password: state.password,
        goToRegistry: state.goToRegistry,
        areMasterFilesChecked: state.areMasterFilesChecked,
        isLogin: state.isLogin,
        isPasswordVisible: state.isPasswordVisible,
        isProfileChecked: state.isProfileChecked,
        notConfirmedUserTryingToLogin: state.notConfirmedUserTryingToLogin,
      ),);
    });

  }

  FormErrorTypes? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return FormErrorTypes.usernameEmptyOrNullError;
    }
    return null;
  }

  FormErrorTypes? validateEmail(String? value) {
    if (!state.isLogin) {
      if (isEmail(value)) {
        return null;
      } else {
        return FormErrorTypes.emailFormatError;
      }
    } else {
      return null;
    }
  }

  // FormErrorTypes? validatePassword(String? value) => validatePasswordOrNull(value);
  // FormErrorTypes? validateRepeatPassword(String? value, String password) {
  //   if (state.isLogin) {
  //     return null;
  //   } else {
  //     if (value.isEmptyOrNull()) {
  //       return FormErrorTypes.emptyRepeatPassword;
  //     } else {
  //       if (validatePasswordOrNull(password) == null) {
  //         if (value != password) {
  //           return FormErrorTypes.repeatPasswordError;
  //         } else {
  //           return null;
  //         }
  //       } else {
  //         return null;
  //       }
  //     }
  //   }
  // }

  Future<void> _onSendVerificationCodeSuccess(SignUpResult signUpResult, Function action, Function removeLoading) async {
    await _fetchUserAttributes(action, isFromVerificationCode: true, removeLoading: removeLoading);
  }

  void _onSendVerificationCodeError(Object error) {
    state.errorTypes = ErrorTypes.sendVerificationCodeError;
  }

  Future<void> _fetchUserAttributes(
      Function moveToNextScreen,
      {
        bool isFromVerificationCode = false,
        bool isFromLogin = false,
        required Function removeLoading,
      }) async {
    if (isFromLogin) await signOutInteractor.execute();

    launchSync(
        block: () async => await fetchUserAttributesInteractor.execute(),
        onSuccess: (CognitoAuthSession session) async {
          if (!isUserConfirmedFromToken(session.userPoolTokens?.idToken)) {
            state.notConfirmedUserTryingToLogin = true;
            removeLoading.call();
          } else if (isFromVerificationCode) {
            await _saveUserInRemoteUsersDatabase(
              session.userSub.orEmpty(),
                  () async => await _onFetchUserAttributesSuccess(session, moveToNextScreen, removeLoading),
              removeLoading,
            );
          } else {
            await _onFetchUserAttributesSuccess(session, moveToNextScreen, removeLoading);
          }
        },
        onError: (error) async => await _onFetchUserAttributesError(error, moveToNextScreen, removeLoading),
    );
  }

  Future<void> _onFetchUserAttributesSuccess(CognitoAuthSession session, Function moveToNextScreen, Function removeLoading) async {
    launchSync(
        block: () async => await saveUserCredentialsInteractor.execute(session),
        onSuccess: (_) async {
          if (session.isSignedIn) {
            if (!state.isProfileChecked) {
              launchSync(
                  block: () async => await checkProfileExistenceInteractor.execute(session.userSub.orEmpty()),
                  onSuccess: (profileExists) async {
                    state.isProfileChecked = true;
                    if (!profileExists) {
                      String? email = getEmailFromToken(getIdTokenInteractor.execute());
                      if (email.isNotNull()) {
                        await _downloadProfile(email.orEmpty(), moveToNextScreen, removeLoading);
                      } else {
                        state.errorTypes = ErrorTypes.getEmailFromTokenError;
                        removeLoading.call();
                      }
                    } else {
                      await _manageMasterFiles(moveToNextScreen, removeLoading);
                    }
                  },
                  onError: (error) {
                    state.errorTypes = ErrorTypes.profileExistenceError;
                    removeLoading.call();
                  },);
            } else {
              if (!state.areMasterFilesChecked) {
                await _manageMasterFiles(moveToNextScreen, removeLoading);
              } else {
                moveToNextScreen.call();
                removeLoading.call();
              }
            }
          } else {
            await _performSignIn(state.username.orEmpty(), state.password.orEmpty(), moveToNextScreen, removeLoading);
          }
        },
        onError: (error) {
          state.errorTypes = ErrorTypes.saveUserCredentialsError;
          removeLoading.call();
        },
    );
  }

  Future<void> _onFetchUserAttributesError(Object error, Function action, Function removeLoading) async {
    if (error is UserNotConfirmedException) {
      state.notConfirmedUserTryingToLogin = true;
      removeLoading.call();
    } else if (error is SignedOutException) {
      await _performSignIn(state.username.orEmpty(), state.password.orEmpty(), action, removeLoading);
    } else {
      state.errorTypes = ErrorTypes.fetchUserCredentialsError;
      removeLoading.call();
    }
  }

  Future<void> _saveUserInRemoteUsersDatabase(String userId, Function finishFetchUserAttributes, Function removeLoading) async {
    final simpleUser = SimpleUser(email: state.email.orEmpty(), userName: state.username.orEmpty(), userId: userId);
    launchSync(
      block: () async => await saveUserInUsersRemoteDatabaseInteractor.execute(simpleUser),
      onSuccess: (_) async => await finishFetchUserAttributes.call(),
      onError: (error) {
        state.errorTypes = ErrorTypes.saveUserInRemoteDatabaseError;
        removeLoading.call();
        },
    );
  }

  Future<void> _performSignIn(String username, String password, Function action, Function removeLoading) async {
    launchSync(
        block: () async => await signInInteractor.execute(
          username.orEmpty(),
          password.orEmpty(),
        ),
        onSuccess: (SignInResult result) async => await _fetchUserAttributes(action, removeLoading: removeLoading),
        onError: (error) async => await _onSignInError(error, removeLoading),
    );
  }

  Future<void> _manageMasterFiles(Function? onFinish, Function removeLoading) async {
    launchSync(
        block: () async => await manageMasterFilesInteractor.execute(
          await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethods),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethodsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.foodsAndDrinksNames),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.nutrientsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.objectivesInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.recommendationGroups),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.sportsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.unitsInfo),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.unitsFoods),
          await getMasterFilesVersionInteractor.execute(MasterFilesType.subjectiveAnalysis),
        ),
        onSuccess: (MasterFilesResponse masterFilesResponse) async => await _onSuccessManageMasterFiles(masterFilesResponse, onFinish, removeLoading),
        onError: (error) async => await _onErrorManageMasterFiles(error, removeLoading),
    );
  }

  Future<void> _onSuccessManageMasterFiles(MasterFilesResponse masterFilesResponse, Function? onFinish, Function removeLoading) async {
    masterFilesResponse.cookingMethodsResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsResponse,
          MasterFilesType.cookingMethods,
      );
    });
    masterFilesResponse.cookingMethodsInfoResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.cookingMethodsInfoResponse,
          MasterFilesType.cookingMethodsInfo,
      );
    });
    masterFilesResponse.foodsAndDrinksNamesResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.foodsAndDrinksNamesResponse,
          MasterFilesType.foodsAndDrinksNames,
      );
    });
    masterFilesResponse.nutrientsInfoResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.nutrientsInfoResponse,
          MasterFilesType.nutrientsInfo,
      );
    });
    masterFilesResponse.objectivesResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(masterFilesResponse.objectivesResponse,
          MasterFilesType.objectivesInfo,
      );
    });
    masterFilesResponse.recommendationGroupsResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.recommendationGroupsResponse,
          MasterFilesType.recommendationGroups,
      );
    });
    masterFilesResponse.sportsInfoResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.sportsInfoResponse,
          MasterFilesType.sportsInfo,
      );
    });
    masterFilesResponse.unitsFoodsResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.unitsFoodsResponse,
          MasterFilesType.unitsFoods,
      );
    });
    masterFilesResponse.unitsInfoResponse.doIfAintNull(() async {
      await saveMasterFileInteractor.execute(
          masterFilesResponse.unitsInfoResponse,
          MasterFilesType.unitsInfo,
      );
    });
    state.areMasterFilesChecked = true;
    onFinish?.call();
    removeLoading.call();
  }

  Future<void> _onErrorManageMasterFiles(Object error, Function removeLoading) async {
    state.areMasterFilesChecked = false;
    state.errorTypes = ErrorTypes.manageMasterFilesError;
    removeLoading.call();
  }

  Future<void> _downloadProfile(String email, Function? moveToNextScreen, Function removeLoading) async {
    launchSync(
      block: () async => await downloadProfileInteractor.execute(email.orEmpty()),
      onSuccess: (UserProfileModel? userProfileModel) async {
        if (userProfileModel.isNull()) {
          await _manageMasterFiles(() => state.goToRegistry?.call(), removeLoading);
        } else {
          await _saveProfileInLocal(userProfileModel!, moveToNextScreen!, removeLoading);
        }
      },
      onError: (error) {
        state.isProfileChecked = false;
        state.errorTypes = ErrorTypes.downloadProfileError;
        removeLoading.call();
        },
    );
  }

  Future<void> _onSignInError(Object error, Function removeLoading) async {
    if (error is UserNotConfirmedException) {
      state.notConfirmedUserTryingToLogin = true;
    } else if (error is NotAuthorizedException) {
      state.errorTypes = ErrorTypes.notAuthorizedError;
    } else {
      state.errorTypes = ErrorTypes.unknownError;
    }
    removeLoading.call();
  }

  Future<void> _saveProfileInLocal(UserProfileModel userProfileModel, Function? moveToNextScreen, Function removeLoading) async {
    launchSync(
      block: () async => await saveProfileInteractor.execute(userProfileModel),
      onSuccess: (_) async => await _manageMasterFiles(moveToNextScreen, removeLoading),
      onError: (error) {
        state.isProfileChecked = false;
        state.errorTypes = ErrorTypes.saveProfileInLocalError;
        removeLoading.call();
      },
    );
  }

  Future<void> _onSignUpSuccess(SignUpResult result, Function action, Function finishAction) async {
    await _saveUsernameAndEmail(state.username.orEmpty(), state.email.orEmpty(), finishAction);
    action.call();
  }

  void _onSignUpError(Object error) {
    if (error is UsernameExistsException) {
      // TODO: enseñar cartel de que tiene que usar otro nombre
      state.errorTypes = ErrorTypes.usernameExistsError;
    } else {
      state.errorTypes = ErrorTypes.unknownError;
    }
  }

  Future<void> _saveUsernameAndEmail(String username, String email, Function finish) async {
    saveUsernameAndEmailInteractor.execute(username, email);
    finish.call();
  }

  void _changePasswordVisibility() {
    state.isPasswordVisible = !state.isPasswordVisible;
  }

  void _changeLoginMode(Function action) {
    state.isLogin = !state.isLogin;
    if (!state.isLogin) {
      action.call();
    }
  }

}