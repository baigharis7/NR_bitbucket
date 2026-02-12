import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/events_sync_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/repository/eventssync/events_synchronization_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_verification_code_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/validator_utils.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProviderNew extends BaseProvider {

  LoginProviderNew();

  SignUpInteractor? signUpInteractor;
  SendVerificationCodeInteractor? verificationCodeInteractor;
  FetchUserAttributesInteractor? fetchUserAttributesInteractor;
  SignInInteractor? signInInteractor;
  SaveUsernameAndEmailInteractor? saveUsernameAndEmailInteractor;
  GetMasterFileVersionInteractor? getMasterFilesVersionInteractor;
  ManageMasterFilesInteractor? manageMasterFilesInteractor;
  SaveMasterFileInteractor? saveMasterFileInteractor;
  CheckProfileExistenceInteractor? checkProfileExistenceInteractor;
  DownloadProfileInteractor? downloadProfileInteractor;
  GetIdTokenInteractor? getIdTokenInteractor;
  SaveProfileInteractor? saveProfileInteractor;
  ResendVerificationCodeInteractor? resendVerificationCodeInteractor;
  SaveUserCredentialsInteractor? saveUserCredentialsInteractor;
  SaveUserInUsersRemoteDatabaseInteractor? saveUserInUsersRemoteDatabaseInteractor;
  SignOutInteractor? signOutInteractor;
  CognitoAuthenticationService? authenticationService;
  SynchronizeEventsInteractor? synchronizeEventsInteractor;
  GetUserIdInteractor? getUserIdInteractor;
  EraseDatabaseInteractor? eraseDatabaseInteractor;

  get getNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;
  get isLogin => _loginMode;
  bool get isPrivacyPolicyChecked => _isPrivacyPolicyChecked;
  String? get getEmail => _email.orEmpty();
  String? get getUsername => _username.orEmpty();
  String? get getPassword => _password.orEmpty();
  get isLoginMode => _loginMode;
  get areMasterFilesChecked => _masterFilesChecked;
  get isProfileChecked => _profileChecked;
  get goToRegistry => _goToRegistry;
  get isNotConfirmedUserTryingToLogin => _notConfirmedUserTryingToLogin;
  bool get isPasswordVisible => _passwordVisible;
  bool get isRepeatPasswordVisible => _repeatPasswordVisible;

  String? _email;
  String? _username;
  String? _password;
  bool _loginMode = true;
  bool _isPrivacyPolicyChecked = false;
  bool _masterFilesChecked = false;
  bool _profileChecked = false;
  Function? _goToRegistry;
  bool _notConfirmedUserTryingToLogin = false;
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;
  bool goesToRegistry = false;

  void _setLoginMode(bool isLoginOn) {
    _loginMode = isLoginOn;
    notifyListeners();
  }

  void setPrivacyPolicyChecked(bool isPrivacyPolicyChecked) {
    _isPrivacyPolicyChecked = isPrivacyPolicyChecked;
    notifyListeners();
  }

  void _setEmail(String email) => _email = email;
  void _setUserName(String username) => _username = username;
  void _setPassword(String password) => _password = password;
  void _setGoToRegistry(Function goToRegistry) => _goToRegistry = goToRegistry;
  void _setMasterFilesChecked(bool masterFilesChecked) => _masterFilesChecked = masterFilesChecked;
  void _setProfileChecked(bool profileChecked) => _profileChecked = profileChecked;
  void _setNotConfirmedUserTryingToLogin(bool notConfirmedUserTryingToLogin) {
    _notConfirmedUserTryingToLogin = notConfirmedUserTryingToLogin;
    notifyListeners();
  }

  @override
  void initialize(Function onError) async {
    super.initialize(onError);

    authenticationService = await CognitoAuthenticationService.init();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Chuck chuck = Chuck(
      showNotification: true,
      showInspectorOnShake: true,
      darkTheme: false,
      maxCallsCount: 1000,
    );
    Preferences prefs = PreferencesImpl(sharedPreferences);
    PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
    fetchUserAttributesInteractor = FetchUserAttributesInteractorImpl(authenticationService: authenticationService!);
    getIdTokenInteractor = GetIdTokenInteractorImpl(preferencesRepository: prefsRepository);
    ProfileApi profileApi = ProfileApi(prefsRepository, authenticationService!, chuck);
    LoginRepository loginRepository = LoginRepositoryImpl(authenticationService: authenticationService!, profileApi: profileApi,);
    saveUserCredentialsInteractor = SaveUserCredentialsInteractorImpl(preferencesRepository: prefsRepository);
    signUpInteractor = SignUpInteractorImpl(loginRepository: loginRepository);
    verificationCodeInteractor = SendVerificationCodeInteractorImpl(loginRepository: loginRepository);
    signInInteractor = SignInInteractorImpl(loginRepository: loginRepository);
    LocalStorageRepository localStorageRepository = LocalStorageImpl();
    ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository);
    saveUsernameAndEmailInteractor = SaveUsernameAndEmailInteractorImpl(preferencesRepository: prefsRepository);
    saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);
    MasterFilesApi masterFilesApi = MasterFilesApi(prefsRepository, authenticationService!, chuck);
    final referenceDatabase = await openReferenceDatabase();
    MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(localStorageRepository: localStorageRepository, masterFilesApi: masterFilesApi, referenceDatabase: referenceDatabase);
    getMasterFilesVersionInteractor = GetMasterFileVersionInteractorImpl(masterFilesRepository: masterFilesRepository);
    manageMasterFilesInteractor = ManageMasterFilesInteractorImpl(masterFilesRepository: masterFilesRepository);
    saveMasterFileInteractor = SaveMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);
    checkProfileExistenceInteractor = CheckProfileExistenceInteractorImpl(profileRepository: profileRepository);
    downloadProfileInteractor = DownloadProfileInteractorImpl(profileRepository: profileRepository);
    resendVerificationCodeInteractor = ResendVerificationCodeInteractorImpl(loginRepository: loginRepository);
    saveUserInUsersRemoteDatabaseInteractor = SaveUserInUsersRemoteDatabaseInteractorImpl(loginRepository: loginRepository);
    signOutInteractor = SignOutInteractorImpl(authenticationService: authenticationService!);
    EventsSyncApi eventsSyncApi = EventsSyncApi(prefsRepository, authenticationService!, chuck);
    EventsSynchronizationRequestRepository eventsSynchronizationRequestRepository = EventsSynchronizationRequestRepositoryImpl(localStorageRepository: localStorageRepository, eventsSyncApi: eventsSyncApi, preferencesRepository: prefsRepository);
    synchronizeEventsInteractor = SynchronizeEventsInteractorImpl(eventsSynchronizationRequestRepository: eventsSynchronizationRequestRepository);
    getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
    eraseDatabaseInteractor = EraseDatabaseInteractorImpl(localStorageRepository: localStorageRepository);
  }

  void changeLoginMode(Function action) {
    _setLoginMode(!isLogin);
    notifyListeners();
    if (!isLogin) {
      action.call();
    }
  }

  void changePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void changeRepeatPasswordVisibility() {
    _repeatPasswordVisible = !_repeatPasswordVisible;
    notifyListeners();
  }

  void submitData({
    required String username,
    required String email,
    required String password,
    required String repeatPassword,
    required Function action,
    required Function goToRegistry,
  }) async {

    manageLoading(true);

    _setEmail(email.orEmpty());
    _setUserName(username.orEmpty());
    _setPassword(password.orEmpty());
    _setGoToRegistry(goToRegistry);

    if (isLogin) {
      _performLogin(username: username, password: password, moveToNextScreen: action);
    } else {
      goesToRegistry = true;
      _performSignUp(username: username, email: email, password: password, action: action);
    }
  }

  void _onSignUpSuccess(SignUpResult result, Function action) {
    _saveUsernameAndEmail(getUsername.orEmpty(), getEmail.orEmpty());
    manageLoading(false);
    action.call();
  }

  void _onSignUpError(Object error) {
    onError?.call(error);

    // if (error is UsernameExistsException) {
    //   onError?.call(ErrorTypes.usernameExistsError);
    // } else if (error is LimitExceededException) {
    //   onError?.call(ErrorTypes.limitError);
    // } else {
    //   onError?.call(ErrorTypes.unknownError);
    // }
  }

  Future<void> _performLogin({
    required String username,
    required password,
    bool isFromVerificationCode = false,
    required Function moveToNextScreen,
  }) async {
    try {
      _signInAndFetchUserAttributes(moveToNextScreen, isFromVerificationCode: isFromVerificationCode);
    } catch (errorSignOut) {
      manageLoading(false);
      onError?.call(errorSignOut);
      // onError?.call(ErrorTypes.unknownError);
    }
  }

  Future<void> _performSignUp({
    required String username,
    required String email,
    required String password,
    required Function action,
  }) async {
    try {
      final signUp = await signUpInteractor?.execute(
        getUsername.orEmpty(),
        getEmail.orEmpty(),
        getPassword.orEmpty(),
      );
      _onSignUpSuccess(signUp!, action);
    } catch (signUpError) {
      manageLoading(false);
      _onSignUpError(signUpError);
    }
  }

  Future<void> _signInAndFetchUserAttributes(Function moveToNextScreen, {bool isFromVerificationCode = false}) async {
    try {
      final signOut = await signOutInteractor!.execute();
      try {
        final signIn = await signInInteractor!.execute(getUsername.orEmpty(), getPassword.orEmpty());
        if (signIn.isSignedIn) {
          try {
            final fetch = await fetchUserAttributesInteractor!.execute();
            if (!isUserConfirmedFromToken(fetch.userPoolTokens?.idToken)) {
              _setNotConfirmedUserTryingToLogin(true);
            } else if (isFromVerificationCode) {
              _onFetchUserAttributesSuccess(fetch, moveToNextScreen, saveUserInRemote: () => _saveUserInRemoteUsersDatabase(fetch.userSub.orEmpty()));
            } else {
              _onFetchUserAttributesSuccess(fetch, moveToNextScreen);
            }
          } catch (fetchError) {
            manageLoading(false);
            _onFetchUserAttributesError(fetchError);
          }
        } else {
          manageLoading(false);
          // onError?.call(ErrorTypes.signInError);
        }
      } catch (signInError) {
        manageLoading(false);
        _onSignInError(signInError);
      }
    } catch (signOutError) {
      manageLoading(false);
      onError?.call(signOutError);
    }
  }

  void _onSignInError(Object error) {
    onError?.call(error);

    // if (error is UserNotConfirmedException) {
    //   _setNotConfirmedUserTryingToLogin(true);
    // } else if (error is NotAuthorizedException) {
    //   onError?.call(ErrorTypes.notAuthorizedError);
    // } else {
    //   onError?.call(ErrorTypes.signInError);
    // }
  }

  void _saveUserInRemoteUsersDatabase(String userId) async {
    final simpleUser = SimpleUser(email: getEmail.orEmpty(), userName: getUsername.orEmpty(), userId: userId);
    try {
      await saveUserInUsersRemoteDatabaseInteractor?.execute(simpleUser);
    } catch (saveUserInRemote) {
      manageLoading(false);
      onError?.call(saveUserInRemote);
      // onError?.call(ErrorTypes.saveUserInRemoteDatabaseError);
    }
  }

  void _onFetchUserAttributesSuccess(
      CognitoAuthSession session,
      Function moveToNextScreen,
      {Function? saveUserInRemote,}
      ) async {
      try {
        await saveUserCredentialsInteractor?.execute(session);
        await saveUserInRemote?.call();
        final userId = getUserIdInteractor!.execute();
        if (session.isSignedIn) {
          if (!isProfileChecked) {
            try {
              final profileExists = await checkProfileExistenceInteractor?.execute(session.userSub.orEmpty());
              _setProfileChecked(true);
              if (!profileExists!) {
                String? email = getEmailFromToken(getIdTokenInteractor?.execute());
                if (email.isNotNull()) {
                  _downloadProfile(email.orEmpty(), moveToNextScreen);
                } else {
                  manageLoading(false);
                  // onError?.call(ErrorTypes.getEmailFromTokenError);
                }
              } else {
                // Aquí lo de borrar los datos.
                if (session.userSub != userId) {
                  await eraseDatabaseInteractor!.execute();
                  String? email = getEmailFromToken(getIdTokenInteractor?.execute());
                  if (email.isNotNull()) {
                    _downloadProfile(email.orEmpty(), moveToNextScreen);
                  } else {
                    manageLoading(false);
                    // onError?.call(ErrorTypes.getEmailFromTokenError);
                  }
                } else {
                  _manageMasterFiles(userId, moveToNextScreen);
                }
              }
            } catch (profileExistenceError) {
              manageLoading(false);
              _setProfileChecked(false);
              onError?.call(profileExistenceError);
              // onError?.call(ErrorTypes.profileExistenceError);
            }
          } else {
            if (!areMasterFilesChecked) {
              _manageMasterFiles(userId, moveToNextScreen);
            } else {
              moveToNextScreen.call();
            }
          }
        }
      } catch (userCredentialsError) {
        manageLoading(false);
        _onFetchUserAttributesError(userCredentialsError);
      }
  }

  void _onFetchUserAttributesError(Object error) {
    if (error is UserNotConfirmedException) {
      _setNotConfirmedUserTryingToLogin(true);
    } else if (error is NoSuchMethodError) {
      onError?.call();
    } else {
      onError?.call(error);
      // onError?.call(ErrorTypes.fetchUserCredentialsError);
    }
  }

  void _downloadProfile(String email, Function? moveToNextScreen) async {
      try {
        final userProfileModel = await downloadProfileInteractor?.execute(email.orEmpty());
        if (userProfileModel.isNull()) {
          final userId = getUserIdInteractor!.execute();
          _manageMasterFiles(userId, () => goToRegistry());
        } else {
          _saveProfileInLocal(userProfileModel!, moveToNextScreen!);
        }
      } catch (downloadProfileError) {
        manageLoading(false);
        _setProfileChecked(false);
        onError?.call(downloadProfileError);
        // onError?.call(ErrorTypes.downloadProfileError);
      }
  }

  void _saveProfileInLocal(UserProfileModel userProfileModel, Function? moveToNextScreen) async {
    try {
      await saveProfileInteractor?.execute(userProfileModel);
      final userId = getUserIdInteractor!.execute();
      _manageMasterFiles(userId, moveToNextScreen);
    } catch (saveProfileError) {
      manageLoading(false);
      _setProfileChecked(false);
      onError?.call(saveProfileError);
      // onError?.call(ErrorTypes.saveProfileInLocalError);
    }
  }

  void _saveUsernameAndEmail(String username, String email) {
    saveUsernameAndEmailInteractor?.execute(username, email);
  }

  Future<void> _synchronizeEvents(String userId) async {
    await synchronizeEventsInteractor!.execute(userId, fullSync: true);
  }

  void notConfirmedUserAsksForNewVerificationCode(Function showMfaDialog) {
    _setNotConfirmedUserTryingToLogin(false);
    try {
      resendVerificationCodeInteractor?.execute(getUsername.orEmpty());
      showMfaDialog.call();
    } catch (resendVerificationCodeError) {
      manageLoading(false);
      onError?.call(resendVerificationCodeError);
      // onError?.call(ErrorTypes.resendVerificationCodeError);
    }
  }

  void resendVerificationCode() async {
    manageLoading(true);
      try {
        await resendVerificationCodeInteractor?.execute(_username.orEmpty());
        manageLoading(false);
      } catch (error) {
        manageLoading(false);
        onError?.call(error);
        // if (error is LimitExceededException) {
        //   onError?.call(ErrorTypes.limitError);
        // } else {
        //   onError?.call(ErrorTypes.resendVerificationCodeError);
        // }
      }
  }

  void _manageMasterFiles(String userId, Function? onFinish) async {
    try {
      manageMasterFilesInteractor?.execute(
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.cookingMethods),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.cookingMethodsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.oilTypes),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.conversionFactors),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.conversionFactorsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.foodsAndDrinksNames),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.nutrientsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.objectivesInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.recommendationGroups),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.sportsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.unitsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.unitsFoods),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.supplementsInfo),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.subjectiveAnalysis),
        await getMasterFilesVersionInteractor!.execute(MasterFilesType.cookingMethodsOilsInfo),
      ).then((masterFilesResponse) => _onSuccessManageMasterFiles(masterFilesResponse, userId, onFinish));
    } catch (errorManageMasterFiles) {
      manageLoading(false);
      _onErrorManageMasterFiles(errorManageMasterFiles);
    }
  }

  void _onSuccessManageMasterFiles(MasterFilesResponse masterFilesResponse, String userId, Function? onFinish) async {
    masterFilesResponse.cookingMethodsResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.cookingMethodsResponse,
        MasterFilesType.cookingMethods,
      );
    });
    masterFilesResponse.cookingMethodsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.cookingMethodsInfoResponse,
        MasterFilesType.cookingMethodsInfo,
      );
    });
    masterFilesResponse.oilTypesResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.oilTypesResponse,
        MasterFilesType.oilTypes,
      );
    });
    masterFilesResponse.conversionFactorsResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.conversionFactorsResponse,
        MasterFilesType.conversionFactors,
      );
    });
    masterFilesResponse.conversionFactorsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.conversionFactorsInfoResponse,
        MasterFilesType.conversionFactorsInfo,
      );
    });
    masterFilesResponse.foodsAndDrinksNamesResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.foodsAndDrinksNamesResponse,
        MasterFilesType.foodsAndDrinksNames,
      );
    });
    masterFilesResponse.nutrientsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.nutrientsInfoResponse,
        MasterFilesType.nutrientsInfo,
      );
    });
    masterFilesResponse.objectivesResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(masterFilesResponse.objectivesResponse,
        MasterFilesType.objectivesInfo,
      );
    });
    masterFilesResponse.recommendationGroupsResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.recommendationGroupsResponse,
        MasterFilesType.recommendationGroups,
      );
    });
    masterFilesResponse.sportsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.sportsInfoResponse,
        MasterFilesType.sportsInfo,);
    });
    masterFilesResponse.unitsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.unitsInfoResponse,
        MasterFilesType.unitsInfo,);
    });
    masterFilesResponse.unitsFoodsResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.unitsFoodsResponse,
        MasterFilesType.unitsFoods,
      );
    });

    masterFilesResponse.supplementsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.supplementsInfoResponse,
        MasterFilesType.supplementsInfo,
      );
    });
    masterFilesResponse.cookingMethodsOilsInfoResponse.doIfAintNull(() {
      saveMasterFileInteractor?.execute(
        masterFilesResponse.cookingMethodsOilsInfoResponse,
        MasterFilesType.cookingMethodsOilsInfo,
      );
    });

    _setMasterFilesChecked(true);
    try {
      await _synchronizeEvents(userId).then((_) {
        manageLoading(false);
        goesToRegistry
            ? goToRegistry.call()
            : onFinish?.call();
      });
    } catch (synchronizeEventError) {
      manageLoading(false);
      onError?.call(synchronizeEventError);
      // onError?.call(ErrorTypes.synchronizeEventsError);
    }
  }

  void _onErrorManageMasterFiles(Object error) {
    _setMasterFilesChecked(false);
    onError?.call(error);
    // onError?.call(ErrorTypes.manageMasterFilesError);
  }

  void notConfirmedUserCancelsReceiveConfirmationCode() {
    _setNotConfirmedUserTryingToLogin(false);
    notifyListeners();
  }

  void sendVerificationCode({
    required String confirmationCode,
    required Function action,
    required Function alreadyExistsAlias,
  }) async {
    manageLoading(true);
    try {
      final signUpResult = await verificationCodeInteractor?.execute(confirmationCode, getUsername.orEmpty());
      _onSendVerificationCodeSuccess(signUpResult!, action);
    } catch (sendVerificationCodeError) {
      manageLoading(false);
      _onSendVerificationCodeError(sendVerificationCodeError,);
    }
  }

  void _onSendVerificationCodeSuccess(SignUpResult signUpResult, Function action) {
    _signInAndFetchUserAttributes(action, isFromVerificationCode: true);
  }

  void _onSendVerificationCodeError(Object error) {
    onError?.call(error);
    // if (error is AliasExistsException) {
    //   onError?.call(ErrorTypes.emailAlreadyExistsError);
    // } else if (error is CodeExpiredException) {
    //   onError?.call(ErrorTypes.codeExpiredError);
    // } else {
    //   onError?.call(ErrorTypes.confirmationCodeError);
    // }
    // _setLoginMode(true);
  }

  FormErrorTypes? validateUsername(String? username) {
    if (isLogin) {
      return null;
    }
    if (username == null || username.isEmpty) {
      return FormErrorTypes.usernameEmptyOrNullError;
    }
    if (username.contains(' ')) {
      return FormErrorTypes.usernameContainsSpacesError;
    }
    return null;
  }

  FormErrorTypes? validateEmail(String? value) {
    if (isLogin) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return FormErrorTypes.emailFormatError;
    }
    if (!isEmail(value)) {
      return FormErrorTypes.emailFormatError;
    }
    return null;
  }

  FormErrorTypes? validatePassword(String? value) => validatePasswordOrNull(isLogin, value);

  FormErrorTypes? validateRepeatPassword(String? value, String password) {
    if (isLogin) {
      return null;
    }
    if (value.isEmptyOrNull()) {
      return FormErrorTypes.emptyRepeatPassword;
    }
    if (password.isNotEmpty && value != password) {
      return FormErrorTypes.repeatPasswordError;
    }
    return null;
  }

}