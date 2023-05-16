// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
// import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
// import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
// import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
// import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
// import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
// import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
// import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
// import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
// import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
// import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/send_verification_code_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
// import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor_impl.dart';
// import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
// import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
// import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
// import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
// import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
// import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
// import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
// import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
// import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
// import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
// import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
// import 'package:nutrenaissance_flutter/infrastructure/utils/validator_utils.dart';
// import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LoginProvider extends BaseProvider {
//
//   LoginProvider();
//
//   SignUpInteractor? signUpInteractor;
//   SendVerificationCodeInteractor? verificationCodeInteractor;
//   FetchUserAttributesInteractor? fetchUserAttributesInteractor;
//   SignInInteractor? signInInteractor;
//   SaveUsernameAndEmailInteractor? saveUsernameAndEmailInteractor;
//   GetMasterFileVersionInteractor? getMasterFilesVersionInteractor;
//   ManageMasterFilesInteractor? manageMasterFilesInteractor;
//   SaveMasterFileInteractor? saveMasterFileInteractor;
//   CheckProfileExistenceInteractor? checkProfileExistenceInteractor;
//   DownloadProfileInteractor? downloadProfileInteractor;
//   GetIdTokenInteractor? getIdTokenInteractor;
//   SaveProfileInteractor? saveProfileInteractor;
//   ResendVerificationCodeInteractor? resendVerificationCodeInteractor;
//   SaveUserCredentialsInteractor? saveUserCredentialsInteractor;
//   SaveUserInUsersRemoteDatabaseInteractor? saveUserInUsersRemoteDatabaseInteractor;
//   SignOutInteractor? signOutInteractor;
//
//   get getNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;
//   get isLogin => _loginMode;
//   String? get getEmail => _email.orEmpty();
//   String? get getUsername => _username.orEmpty();
//   String? get getPassword => _password.orEmpty();
//   get isLoginMode => _loginMode;
//   get areMasterFilesChecked => _masterFilesChecked;
//   get isProfileChecked => _profileChecked;
//   get goToRegistry => _goToRegistry;
//   get isNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;
//   bool get isPasswordVisible => _passwordVisible;
//   bool get isRepeatPasswordVisible => _repeatPasswordVisible;
//
//   String? _email;
//   String? _username;
//   String? _password;
//   bool _loginMode = true;
//   bool _masterFilesChecked = false;
//   bool _profileChecked = false;
//   Function? _goToRegistry;
//   bool _notConfirmedUserTryingToLogin = false;
//   bool _passwordVisible = false;
//   bool _repeatPasswordVisible = false;
//   bool goesToRegistry = false;
//
//   @override
//   void initialize(Function onError) async {
//     super.initialize(onError);
//
//     CognitoAuthenticationService authenticationService = await CognitoAuthenticationService.init();
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     Preferences prefs = PreferencesImpl(sharedPreferences);
//     PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
//     fetchUserAttributesInteractor = FetchUserAttributesInteractorImpl(authenticationService: authenticationService);
//     getIdTokenInteractor = GetIdTokenInteractorImpl(preferencesRepository: prefsRepository);
//     ProfileApi profileApi = ProfileApi(prefsRepository, authenticationService);
//     LoginRepository loginRepository = LoginRepositoryImpl(authenticationService: authenticationService, profileApi: profileApi,);
//     saveUserCredentialsInteractor = SaveUserCredentialsInteractorImpl(preferencesRepository: prefsRepository);
//     signUpInteractor = SignUpInteractorImpl(loginRepository: loginRepository);
//     verificationCodeInteractor = SendVerificationCodeInteractorImpl(loginRepository: loginRepository);
//     signInInteractor = SignInInteractorImpl(loginRepository: loginRepository);
//     LocalStorageRepository localStorageRepository = LocalStorageImpl();
//     ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository);
//     saveUsernameAndEmailInteractor = SaveUsernameAndEmailInteractorImpl(preferencesRepository: prefsRepository);
//     saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);
//     MasterFilesApi masterFilesApi = MasterFilesApi(prefsRepository, authenticationService);
//     MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(localStorageRepository: localStorageRepository, masterFilesApi: masterFilesApi);
//     getMasterFilesVersionInteractor = GetMasterFileVersionInteractorImpl(masterFilesRepository: masterFilesRepository);
//     manageMasterFilesInteractor = ManageMasterFilesInteractorImpl(masterFilesRepository: masterFilesRepository);
//     saveMasterFileInteractor = SaveMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);
//     checkProfileExistenceInteractor = CheckProfileExistenceInteractorImpl(profileRepository: profileRepository);
//     downloadProfileInteractor = DownloadProfileInteractorImpl(profileRepository: profileRepository);
//     resendVerificationCodeInteractor = ResendVerificationCodeInteractorImpl(loginRepository: loginRepository);
//     saveUserInUsersRemoteDatabaseInteractor = SaveUserInUsersRemoteDatabaseInteractorImpl(loginRepository: loginRepository);
//     signOutInteractor = SignOutInteractorImpl(authenticationService: authenticationService);
//   }
//
//   void changeLoginMode(Function action) {
//     _setLoginMode(!isLogin);
//     notifyListeners();
//     if (!isLogin) {
//       action.call();
//     }
//   }
//
//   void changePasswordVisibility() {
//     _passwordVisible = !_passwordVisible;
//     notifyListeners();
//   }
//
//   void changeRepeatPasswordVisibility() {
//     _repeatPasswordVisible = !_repeatPasswordVisible;
//     notifyListeners();
//   }
//
//   void submitData({
//     required String username,
//     required String email,
//     required String password,
//     required String repeatPassword,
//     required Function action,
//     required Function goToRegistry,
//   }) async {
//     _setEmail(email.orEmpty());
//     _setUserName(username.orEmpty());
//     _setPassword(password.orEmpty());
//     _setGoToRegistry(goToRegistry);
//
//     if (isLogin) {
//       _fetchUserAttributes(action, isFromLogin: true);
//     } else {
//       if (password != repeatPassword) {
//         // TODO: manage error.
//
//       } else {
//         goesToRegistry = true;
//         launchSync(
//           block: () => signUpInteractor?.execute(
//               getUsername.orEmpty(),
//               getEmail.orEmpty(),
//               getPassword.orEmpty(),
//             ),
//           onSuccess: (result) => _onSignUpSuccess(result, action),
//           onError: (error) => _onSignUpError(error),);
//       }
//     }
//   }
//
//   void notConfirmedUserAsksForNewVerificationCode(Function showMfaDialog) {
//     _setNotConfirmedUserTryingToLogin(false);
//
//     launchSync(
//       block: () => resendVerificationCodeInteractor?.execute(getUsername.orEmpty()),
//       onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) => showMfaDialog.call(),
//       onError: (error) {
//         onError?.call(ErrorTypes.resendVerificationCodeError);
//       },
//     );
//   }
//
//   void notConfirmedUserCancelsReceiveConfirmationCode() {
//     _setNotConfirmedUserTryingToLogin(false);
//     notifyListeners();
//   }
//
//   FormErrorTypes? validateUsername(String? username) {
//     if (username == null || username.isEmpty) {
//       return FormErrorTypes.usernameEmptyOrNullError;
//     }
//     return null;
//   }
//
//   FormErrorTypes? validateEmail(String? value) {
//     if (!isLogin) {
//       if (isEmail(value)) {
//         return null;
//       } else {
//         return FormErrorTypes.emailFormatError;
//       }
//     } else {
//       return null;
//     }
//   }
//
//   FormErrorTypes? validatePassword(String? value) => validatePasswordOrNull(value);
//   FormErrorTypes? validateRepeatPassword(String? value, String password) {
//     if (isLogin) {
//       return null;
//     } else {
//       if (value.isEmptyOrNull()) {
//         return FormErrorTypes.emptyRepeatPassword;
//       } else {
//         if (validatePasswordOrNull(password) == null) {
//           if (value != password) {
//             return FormErrorTypes.repeatPasswordError;
//           } else {
//             return null;
//           }
//         } else {
//           return null;
//         }
//       }
//     }
//   }
//
//   void _setLoginMode(bool isLogin) => _loginMode = isLogin;
//   void _setEmail(String email) => _email = email;
//   void _setUserName(String username) => _username = username;
//   void _setPassword(String password) => _password = password;
//   void _setGoToRegistry(Function goToRegistry) => _goToRegistry = goToRegistry;
//   void _setMasterFilesChecked(bool masterFilesChecked) => _masterFilesChecked = masterFilesChecked;
//   void _setProfileChecked(bool profileChecked) => _profileChecked = profileChecked;
//   void _setNotConfirmedUserTryingToLogin(bool notConfirmedUserTryingToLogin) => _notConfirmedUserTryingToLogin = notConfirmedUserTryingToLogin;
//
//   void _onSignInError(Object error) {
//     if (error is UserNotConfirmedException) {
//       _setNotConfirmedUserTryingToLogin(true);
//     } else if (error is NotAuthorizedException) {
//       onError?.call(ErrorTypes.notAuthorizedError);
//     } else {
//       onError?.call(ErrorTypes.unknownError);
//     }
//   }
//
//   void _fetchUserAttributes(Function moveToNextScreen, {bool isFromVerificationCode = false, bool isFromLogin = false}) async {
//     if (isFromLogin) await signOutInteractor?.execute();
//
//     launchSync(
//         block: () => fetchUserAttributesInteractor?.execute(),
//         onSuccess: (CognitoAuthSession session) async {
//           if (!isUserConfirmedFromToken(session.userPoolTokens?.idToken)) {
//             _setNotConfirmedUserTryingToLogin(true);
//           } else if (isFromVerificationCode) {
//             _saveUserInRemoteUsersDatabase(session.userSub.orEmpty(), () {
//               _onFetchUserAttributesSuccess(session, moveToNextScreen);
//             });
//           } else {
//             _onFetchUserAttributesSuccess(session, moveToNextScreen);
//           }
//         },
//         onError: (error) => _onFetchUserAttributesError(error, moveToNextScreen),);
//   }
//
//   void _onSignUpSuccess(SignUpResult result, Function action) {
//     _saveUsernameAndEmail(getUsername.orEmpty(), getEmail.orEmpty());
//     action.call();
//   }
//
//   void _onSignUpError(Object error) {
//     if (error is UsernameExistsException) {
//       // TODO: enseñar cartel de que tiene que usar otro nombre
//       onError?.call(ErrorTypes.usernameExistsError);
//     } else {
//       onError?.call(ErrorTypes.unknownError);
//     }
//   }
//
//   void sendVerificationCode(String confirmationCode, Function action) {
//     launchSync(
//       block: () => verificationCodeInteractor?.execute(confirmationCode, getUsername.orEmpty()),
//       onSuccess: (signUpResult) => _onSendVerificationCodeSuccess(signUpResult, action),
//       onError: (error) => _onSendVerificationCodeError(error),
//     );
//   }
//
//   void _onSendVerificationCodeSuccess(SignUpResult signUpResult, Function action) {
//     _fetchUserAttributes(action, isFromVerificationCode: true);
//   }
//
//   void _onSendVerificationCodeError(Object error) {
//     onError?.call(ErrorTypes.sendVerificationCodeError);
//   }
//
//   void _onFetchUserAttributesSuccess(CognitoAuthSession session, Function moveToNextScreen) {
//     launchSync(
//         block: () => saveUserCredentialsInteractor?.execute(session),
//         onSuccess: (_) {
//           if (session.isSignedIn) {
//             if (!isProfileChecked) {
//               launchSync(
//                   block: () => checkProfileExistenceInteractor?.execute(session.userSub.orEmpty()),
//                   onSuccess: (profileExists) {
//                     _setProfileChecked(true);
//                     if (!profileExists) {
//                       String? email = getEmailFromToken(getIdTokenInteractor?.execute());
//                       if (email.isNotNull()) {
//                         downloadProfile(email.orEmpty(), moveToNextScreen);
//                       } else {
//                         onError?.call(ErrorTypes.getEmailFromTokenError);
//                       }
//                     } else {
//                       _manageMasterFiles(moveToNextScreen);
//                     }
//                   },
//                   onError: (error) {
//                     onError?.call(ErrorTypes.profileExistenceError);
//                   });
//             } else {
//               if (!areMasterFilesChecked) {
//                 _manageMasterFiles(moveToNextScreen);
//               } else {
//                 moveToNextScreen.call();
//               }
//             }
//           } else {
//             _performSignIn(getUsername.orEmpty(), getPassword.orEmpty(), moveToNextScreen);
//           }
//         },
//         onError: (error) {
//           onError?.call(ErrorTypes.saveUserCredentialsError);
//         },);
//   }
//
//   void _onFetchUserAttributesError(Object error, Function action) {
//     if (error is UserNotConfirmedException) {
//       _setNotConfirmedUserTryingToLogin(true);
//     } else if (error is SignedOutException) {
//       _performSignIn(getUsername.orEmpty(), getPassword.orEmpty(), action);
//     } else {
//       onError?.call(ErrorTypes.fetchUserCredentialsError);}
//   }
//
//   void downloadProfile(String email, Function? moveToNextScreen) {
//     launchSync(
//       block: () => downloadProfileInteractor?.execute(email.orEmpty()),
//       onSuccess: (UserProfileModel? userProfileModel) {
//         if (userProfileModel.isNull()) {
//           _manageMasterFiles(() => goToRegistry());
//         } else {
//
//           _saveProfileInLocal(userProfileModel!, moveToNextScreen!);
//         }
//       },
//       onError: (error) {
//         _setProfileChecked(false);
//         onError?.call(ErrorTypes.downloadProfileError);      },
//     );
//   }
//
//   void _saveProfileInLocal(UserProfileModel userProfileModel, Function? moveToNextScreen) {
//     launchSync(
//       block: () => saveProfileInteractor?.execute(userProfileModel),
//       onSuccess: (_) => _manageMasterFiles(moveToNextScreen),
//       onError: (error) {
//         _setProfileChecked(false);
//         onError?.call(ErrorTypes.saveProfileInLocalError);
//       },
//     );
//   }
//
//   void _saveUsernameAndEmail(String username, String email) {
//     saveUsernameAndEmailInteractor?.execute(username, email);
//   }
//
//   void resendVerificationCode() {
//     launchSync(
//       block: () => resendVerificationCodeInteractor?.execute(_username.orEmpty()),
//       onSuccess: (ResendSignUpCodeResult resendSignUpCodeResult) {
//         // TODO: ¿avisar de que se ha enviado?
//       },
//       onError: (error) {
//         onError?.call(ErrorTypes.resendVerificationCodeError);
//         },
//     );
//   }
//
//   void _performSignIn(String username, String password, Function action) {
//     launchSync(
//         block: () => signInInteractor?.execute(
//               username.orEmpty(),
//               password.orEmpty(),
//             ),
//         onSuccess: (SignInResult? result) => _fetchUserAttributes(action),
//         onError: (error) => _onSignInError(error),);
//   }
//
//   void _manageMasterFiles(Function? onFinish) {
//     launchSync(
//         block: () async => manageMasterFilesInteractor?.execute(
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.cookingMethods),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.cookingMethodsInfo),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.foodsAndDrinksNames),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.nutrientsInfo),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.objectivesInfo),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.recommendationGroups),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.sportsInfo),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.unitsInfo),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.unitsFoods),
//           await getMasterFilesVersionInteractor!.execute(MasterFilesType.subjectiveAnalysis),
//         ),
//         onSuccess: (MasterFilesResponse masterFilesResponse) => _onSuccessManageMasterFiles(masterFilesResponse, onFinish),
//         onError: (error) => _onErrorManageMasterFiles(error),);
//   }
//
//   void _onSuccessManageMasterFiles(MasterFilesResponse masterFilesResponse, Function? onFinish) {
//     masterFilesResponse.cookingMethodsResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.cookingMethodsResponse,
//           MasterFilesType.cookingMethods,
//       );
//     });
//     masterFilesResponse.cookingMethodsInfoResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.cookingMethodsInfoResponse,
//           MasterFilesType.cookingMethodsInfo,
//       );
//     });
//     masterFilesResponse.foodsAndDrinksNamesResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.foodsAndDrinksNamesResponse,
//           MasterFilesType.foodsAndDrinksNames,
//       );
//     });
//     masterFilesResponse.nutrientsInfoResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.nutrientsInfoResponse,
//           MasterFilesType.nutrientsInfo,
//       );
//     });
//     masterFilesResponse.objectivesResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(masterFilesResponse.objectivesResponse,
//           MasterFilesType.objectivesInfo,
//       );
//     });
//     masterFilesResponse.recommendationGroupsResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.recommendationGroupsResponse,
//           MasterFilesType.recommendationGroups,
//       );
//     });
//     masterFilesResponse.sportsInfoResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.sportsInfoResponse,
//           MasterFilesType.sportsInfo,);
//     });
//     masterFilesResponse.unitsInfoResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.unitsInfoResponse,
//           MasterFilesType.unitsInfo,);
//     });
//     masterFilesResponse.unitsFoodsResponse.doIfAintNull(() {
//       saveMasterFileInteractor?.execute(
//           masterFilesResponse.unitsFoodsResponse,
//           MasterFilesType.unitsFoods,
//       );
//     });
//
//     _setMasterFilesChecked(true);
//     goesToRegistry
//         ? goToRegistry.call()
//         : onFinish?.call();
//   }
//
//   void _onErrorManageMasterFiles(Object error) {
//     _setMasterFilesChecked(false);
//     onError?.call(ErrorTypes.manageMasterFilesError);
//   }
//
//   void _saveUserInRemoteUsersDatabase(String userId, Function finishFetchUserAttributes) {
//     final simpleUser = SimpleUser(email: getEmail.orEmpty(), userName: getUsername.orEmpty(), userId: userId);
//     launchSync(
//       block: () => saveUserInUsersRemoteDatabaseInteractor?.execute(simpleUser),
//       onSuccess: (_) => finishFetchUserAttributes.call(),
//       onError: (error) => onError?.call(ErrorTypes.saveUserInRemoteDatabaseError),
//     );
//   }
//
// }