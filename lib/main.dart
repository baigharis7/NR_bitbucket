import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/api/recommendations/recommendations_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/foodevent/food_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recommendations/recommendations_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/recommendations/recommendations_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/provider/dashboard_provider.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/provider/add_food_event_provider.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/provider/recommendations_provider.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/view/recommendations_screen.dart';
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
  final LocalStorageRepository localStorageRepository = LocalStorageImpl();
  final ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository);
  final SignUpInteractor signUpInteractor = SignUpInteractorImpl(loginRepository: loginRepository);
  final SendVerificationCodeInteractor sendVerificationCodeInteractor = SendVerificationCodeInteractorImpl(loginRepository: loginRepository);
  final SignInInteractor signInInteractor = SignInInteractorImpl(loginRepository: loginRepository);
  final GetUserIdInteractor getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
  final UploadProfileInteractor uploadProfileInteractor = UploadProfileInteractorImpl(profileRepository: profileRepository);
  final SaveUsernameAndEmailInteractor saveUsernameAndEmailInteractor = SaveUsernameAndEmailInteractorImpl(preferencesRepository: prefsRepository);
  final IsUserSignedInInteractor isUserSignedInInteractor = IsUserSignedInInteractorImpl(preferencesRepository: prefsRepository);
  final SaveProfileInteractor saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);
  final FoodEventsApi foodEventsApi = FoodEventsApi(getIdTokenInteractor: getIdTokenInteractor, fetchUserAttributesInteractor: fetchUserAttributesInteractor);
  final FoodEventsRepository foodEventsRepository = FoodEventsRepositoryImpl(localStorageRepository: localStorageRepository, foodEventsApi: foodEventsApi, );
  final UploadFoodEventInteractor uploadFoodEventInteractor = UploadFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final SaveFoodEventInteractor saveFoodEventInteractor = SaveFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final RecommendationsApi recommendationsApi = RecommendationsApi(fetchUserAttributesInteractor: fetchUserAttributesInteractor, getIdTokenInteractor: getIdTokenInteractor);
  final RecommendationsRepository recommendationsRepository = RecommendationsRepositoryImpl(recommendationsApi: recommendationsApi);
  final GetRecommendationInteractor getRecommendationInteractor = GetRecommendationInteractorImpl(recommendationsRepository: recommendationsRepository);
  final GetAllFoodEventsInteractor getAllFoodEventsInteractor = GetAllFoodEventsInteractorImpl(foodEventsRepository: foodEventsRepository);
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor = GetUserMicronutrientsInteractorImpl(profileRepository: profileRepository);
  final MasterFilesApi masterFilesApi = MasterFilesApi(getIdTokenInteractor: getIdTokenInteractor, fetchUserAttributesInteractor: fetchUserAttributesInteractor);
  final MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(localStorageRepository: localStorageRepository, masterFilesApi: masterFilesApi);
  final GetMasterFileVersionInteractor getMasterFileVersionInteractor = GetMasterFileVersionInteractorImpl(masterFilesRepository: masterFilesRepository);
  final ManageMasterFilesInteractor manageMasterFilesInteractor = ManageMasterFilesInteractorImpl(masterFilesRepository: masterFilesRepository);
  final SaveMasterFileInteractor saveMasterFileInteractor = SaveMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);
  final CheckProfileExistenceInteractor checkProfileExistenceInteractor = CheckProfileExistenceInteractorImpl(profileRepository: profileRepository);
  final DownloadProfileInteractor downloadProfileInteractor = DownloadProfileInteractorImpl(profileRepository: profileRepository);
  final ResendVerificationCodeInteractor resendVerificationCodeInteractor = ResendVerificationCodeInteractorImpl(loginRepository: loginRepository);

  final loginProvider = LoginProvider(
      signUpInteractor: signUpInteractor,
      verificationCodeInteractor: sendVerificationCodeInteractor,
      fetchUserAttributesInteractor: fetchUserAttributesInteractor,
      signInInteractor: signInInteractor,
      saveUsernameAndEmailInteractor: saveUsernameAndEmailInteractor,
      isUserSignedInInteractor: isUserSignedInInteractor,
      getMasterFilesVersionInteractor: getMasterFileVersionInteractor,
      manageMasterFilesInteractor: manageMasterFilesInteractor,
      saveMasterFileInteractor: saveMasterFileInteractor,
      checkProfileExistenceInteractor: checkProfileExistenceInteractor,
      downloadProfileInteractor: downloadProfileInteractor,
      getIdTokenInteractor: getIdTokenInteractor,
      saveProfileInteractor: saveProfileInteractor,
      resendVerificationCodeInteractor: resendVerificationCodeInteractor
  );
  // await loginProvider.init();

  final registryProvider = RegistryProvider(
    getUserIdInteractor: getUserIdInteractor,
    uploadProfileInteractor: uploadProfileInteractor,
    saveProfileInteractor: saveProfileInteractor
  );

  final dashboardProvider = DashboardProvider(
      getAllFoodEventsInteractor: getAllFoodEventsInteractor,
      getUserMicronutrientsInteractor: getUserMicronutrientsInteractor
  );

  final addFoodEventProvider = AddFoodEventProvider(
      getUserIdInteractor: getUserIdInteractor,
      saveFoodEventInteractor: saveFoodEventInteractor,
      uploadFoodEventInteractor: uploadFoodEventInteractor
  );

  final recommendationsProvider = RecommendationsProvider(
      getRecommendationInteractor: getRecommendationInteractor,
      getUserIdInteractor: getUserIdInteractor
  );
  // await addFoodEventProvider.init();
  // await dashboardProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // TODO: el interactor es use case, uno por cada caso de uso.
        ChangeNotifierProvider<LoginProvider>(create: (_) => loginProvider),
        ChangeNotifierProvider<RegistryProvider>(create: (_) => registryProvider),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => dashboardProvider),
        ChangeNotifierProvider<AddFoodEventProvider>(create: (_) => addFoodEventProvider),
        ChangeNotifierProvider<RecommendationsProvider>(create: (_) => recommendationsProvider),
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
          AddFoodEventScreen.routeName: (_) => const AddFoodEventScreen(),
          RecommendationsScreen.routeName: (_) => const RecommendationsScreen(),
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
  Hive.registerAdapter(FoodEventEntityAdapter());
  Hive.registerAdapter(FoodInfoAdapter());
  Hive.registerAdapter(EventInfoAdapter());
  Hive.registerAdapter(ParamsAdapter());
  Hive.registerAdapter(CookingMethodsEntityAdapter());
  Hive.registerAdapter(CookingMethodGroupEntityAdapter());
  Hive.registerAdapter(CookingMethodsInfoEntityAdapter());
  Hive.registerAdapter(CookingMethodInfoEntityAdapter());
  Hive.registerAdapter(FoodsAndDrinksNamesEntityAdapter());
  Hive.registerAdapter(FoodsAndDrinkListsEntityAdapter());
  Hive.registerAdapter(FoodItemEntityAdapter());
  Hive.registerAdapter(NutrientsInfoEntityAdapter());
  Hive.registerAdapter(NutrientInfoEntityAdapter());
  Hive.registerAdapter(ObjectivesInfoEntityAdapter());
  Hive.registerAdapter(ObjectiveInfoEntityAdapter());
  Hive.registerAdapter(RecommendationGroupsEntityAdapter());
  Hive.registerAdapter(RecommendationGroupEntityAdapter());
}