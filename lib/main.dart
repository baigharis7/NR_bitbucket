import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/local/local_storage_helper.dart';
import 'package:nutrenaissance_flutter/data/local/local_storage_helper_impl.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_verification_code_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/provider/dashboard_provider.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/registry_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/view/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: Environment.staging);
  Environment().initConfig(environment);
  initLocalStorage();

  WidgetsFlutterBinding.ensureInitialized();

  // TODO: meter todo esto en funciones.
  final authenticationService = await CognitoAuthenticationService.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final Preferences prefs = PreferencesImpl(sharedPreferences);
  final PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
  final SaveUserCredentialsInteractor saveUserCredentialsInteractor = SaveUserCredentialsInteractorImpl(preferencesRepository: prefsRepository);
  final LoginRepository loginRepository = LoginRepositoryImpl(authenticationService: authenticationService, saveUserCredentialsInteractor: saveUserCredentialsInteractor);
  final GetIdTokenInteractor getIdTokenInteractor = GetIdTokenInteractorImpl(preferencesRepository: prefsRepository);
  final FetchUserAttributesInteractor fetchUserAttributesInteractor = FetchUserAttributesInteractorImpl(loginRepository: loginRepository);
  final ProfileApi profileApi = ProfileApi(getIdTokenInteractor: getIdTokenInteractor, fetchUserAttributesInteractor: fetchUserAttributesInteractor);
  final LocalStorageHelper localStorageHelper = LocalStorageHelperImpl();
  final ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageHelper: localStorageHelper);
  final SignUpInteractor signUpInteractor = SignUpInteractorImpl(loginRepository: loginRepository);
  final SendVerificationCodeInteractor sendVerificationCodeInteractor = SendVerificationCodeInteractorImpl(loginRepository: loginRepository);
  final SignInInteractor signInInteractor = SignInInteractorImpl(loginRepository: loginRepository);
  final GetUserIdInteractor getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
  final UploadProfileInteractor uploadProfileInteractor = UploadProfileInteractorImpl(profileRepository: profileRepository);
  final SaveUsernameAndEmailInteractor saveUsernameAndEmailInteractor = SaveUsernameAndEmailInteractorImpl(preferencesRepository: prefsRepository);
  final IsUserSignedInInteractor isUserSignedInInteractor = IsUserSignedInInteractorImpl(preferencesRepository: prefsRepository);
  final SaveProfileInteractor saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);

  final loginProvider = LoginProvider(
      signUpInteractor: signUpInteractor,
      verificationCodeInteractor: sendVerificationCodeInteractor,
      fetchUserAttributesInteractor: fetchUserAttributesInteractor,
      signInInteractor: signInInteractor,
      saveUsernameAndEmailInteractor: saveUsernameAndEmailInteractor,
      isUserSignedInInteractor: isUserSignedInInteractor,
  );
  await loginProvider.init();

  final registryProvider = RegistryProvider(
    getUserIdInteractor: getUserIdInteractor,
    uploadProfileInteractor: uploadProfileInteractor,
    saveProfileInteractor: saveProfileInteractor
  );

  final dashboardProvider = DashboardProvider(
      getAllFoodEventsInteractor: getAllFoodEventsInteractor,
      getUserMicronutrientsInteractor: getUserMicronutrientsInteractor
  );


  // await dashboardProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // TODO: el interactor es use case, uno por cada caso de uso.
        ChangeNotifierProvider<LoginProvider>(create: (_) => loginProvider),
        ChangeNotifierProvider<RegistryProvider>(create: (_) => registryProvider),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => dashboardProvider),
        // ChangeNotifierProxyProvider<ClaseDeLaQueDepende, ClaseQueSeProvee>(
        //     create: (ctx) {},
        //     update: (ctx, dynamic, objetoQueSeProvee) => ClaseQueSeProvee(),
        // ),
      ],
      child: MaterialApp(
        title: 'NutreNaissance',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        initialRoute: '/',
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('es', ''), // Spanish, no country code
        ],
        routes: {
          '/': (ctx) => const LoginScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(context: ctx),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegistryScreen.routeName: (ctx) => RegistryScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
        },
      ),
    ),
  );
}

void initLocalStorage() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileEntityAdapter());
  Hive.registerAdapter(MedicalSituationAdapter());
  Hive.registerAdapter(PhysicalCharacteristicsAdapter());
  Hive.registerAdapter(FemaleCharacteristicsAdapter());
  Hive.registerAdapter(MenstruationAdapter());
  Hive.registerAdapter(ExclusionsAdapter());
  Hive.registerAdapter(SexTypeAdapter());
  Hive.registerAdapter(MenstruationRegularityAdapter());
}