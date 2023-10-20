import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/advices/advices_api.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/favorites_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/liquid_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/api/recipes/recipes_api.dart';
import 'package:nutrenaissance_flutter/data/api/recommendations/recommendations_api.dart';
import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/waterevents/water_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/explainingcards/explaining_card_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/liquidevents/liquid_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/advices/advices_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/calendar/calendar_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/explainingcards/explaining_cards_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/favorites/favorites_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/foodevents/food_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/liquidevents/liquid_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recipes/recipes_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recommendations/recommendations_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/sportevents/sport_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/waterevents/water_event_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/save_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/save_liquid_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/upload_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/upload_liquid_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/repository/advices/advices_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/recommendations/recommendations_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/view/calendar_screen.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/test_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/create_new_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/favorite_foods_cluster_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/favorite_foods_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/add_liquid_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/create_new_liquid_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/create_new_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/favorite_sports_screen.dart';
import 'package:nutrenaissance_flutter/presentation/food/bloc/food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/food/view/food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_liquid_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_sport_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/privacypolicy/privacy_policy.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/food_list_aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/registry/view/registry_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/splash/view/splash_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'domain/interactor/login/erase_database_interactor_impl.dart';
import 'presentation/profile/common/aversions_screen.dart';
import 'presentation/profile/common/health_questions_screen.dart';
import 'presentation/recommendations/common/view/recommendations_tabs_holder.dart';
import 'presentation/waterevent/view/add_water_event_screen.dart';

import 'package:chuck_interceptor/chuck.dart';
void main() async {
  const String environmentName = String.fromEnvironment(Environment.DEV, defaultValue: Environment.DEV);
  Environment().initConfig(environmentName);
  WidgetsFlutterBinding.ensureInitialized();

  initLocalStorage();

  final authenticationService = await CognitoAuthenticationService.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Chuck chuck = Chuck(
    showNotification: true,
    showInspectorOnShake: true,
    darkTheme: false,
    maxCallsCount: 1000,
  );
  final Preferences prefs = PreferencesImpl(sharedPreferences);
  final PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
  final ProfileApi profileApi = ProfileApi(prefsRepository, authenticationService, chuck);
  final LocalStorageRepository localStorageRepository = LocalStorageImpl();
  final ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository);
  final GetUserIdInteractor getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
  final UploadProfileInteractor uploadProfileInteractor = UploadProfileInteractorImpl(profileRepository: profileRepository);
  final SaveProfileInteractor saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);
  final FoodEventsApi foodEventsApi = FoodEventsApi(prefsRepository, authenticationService, chuck);
  final FoodEventsRepository foodEventsRepository = FoodEventsRepositoryImpl(localStorageRepository: localStorageRepository, foodEventsApi: foodEventsApi, );
  final UploadFoodEventInteractor uploadFoodEventInteractor = UploadFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final SaveFoodEventInteractor saveFoodEventInteractor = SaveFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final RecommendationsApi recommendationsApi = RecommendationsApi(prefsRepository, authenticationService, chuck);
  final RecommendationsRepository recommendationsRepository = RecommendationsRepositoryImpl(recommendationsApi: recommendationsApi);
  final GetRecommendationInteractor getRecommendationInteractor = GetRecommendationInteractorImpl(recommendationsRepository: recommendationsRepository);
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor = GetUserMicronutrientsInteractorImpl(profileRepository: profileRepository);
  final MasterFilesApi masterFilesApi = MasterFilesApi(prefsRepository, authenticationService, chuck);
  final MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(localStorageRepository: localStorageRepository, masterFilesApi: masterFilesApi);
  final GetMasterFileInteractor getMasterFileInteractor = GetMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);
  final GetUserRdasInteractor getUserRdasInteractor = GetUserRdasInteractorImpl(localStorageRepository: localStorageRepository);
  final SportEventsApi sportEventsApi = SportEventsApi(prefsRepository, authenticationService, chuck);
  final SportEventsRepository sportEventsRepository = SportEventsRepositoryImpl(sportEventsApi: sportEventsApi, localStorageRepository: localStorageRepository);
  final UploadSportEventsInteractor uploadSportEventsInteractor = UploadSportEventsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final SaveSportEventInteractor saveSportEventInteractor = SaveSportEventInteractorImpl(sportEventsRepository: sportEventsRepository);
  final AdvicesApi advicesApi = AdvicesApi(prefsRepository, authenticationService, chuck);
  final AdvicesRepository advicesRepository = AdvicesRepositoryImpl(advicesApi: advicesApi);
  final GetAdviceInteractor getAdviceInteractor = GetAdviceInteractorImpl(advicesRepository: advicesRepository);
  final GetProfileInteractor getProfileInteractor = GetProfileInteractorImpl(profileRepository: profileRepository);
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor = GetFoodEventsOfTodayInteractorImpl(foodEventsRepository: foodEventsRepository);
  final LiquidEventsApi liquidEventsApi = LiquidEventsApi(prefsRepository, authenticationService, chuck);
  final LiquidEventsRepository liquidEventsRepository = LiquidEventsRepositoryImpl(liquidEventsApi: liquidEventsApi, localStorageRepository: localStorageRepository);
  final SaveLiquidEventInteractor saveLiquidEventInteractor = SaveLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final UploadLiquidEventInteractor uploadLiquidEventInteractor = UploadLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor = GetWeekFoodEventsInteractorImpl(foodEventsRepository: foodEventsRepository);
  final GetUserKcalInteractor getUserKcalInteractor = GetUserKcalInteractorImpl(profileRepository: profileRepository);
  final GetTodaySportsInteractor getTodaySportsInteractor = GetTodaySportsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final GetWeekSportsInteractor getWeekSportsInteractor = GetWeekSportsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor = GetWeekLiquidEventsInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final GetTodayLiquidEventsInteractor getTodayLiquidEventsInteractor = GetTodayLiquidEventsInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final WaterEventsApi waterEventsApi = WaterEventsApi(prefsRepository, authenticationService, chuck);
  final WaterEventsRepository waterEventsRepository = WaterEventRepositoryImpl(localStorageRepository: localStorageRepository, waterEventsApi: waterEventsApi);
  final UploadWaterEventInteractor uploadWaterEventInteractor = UploadWaterEventInteractorImpl(waterEventsRepository: waterEventsRepository);
  final SaveWaterEventInteractor saveWaterEventInteractor = SaveWaterEventInteractorImpl(waterEventsRepository: waterEventsRepository);
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor = GetWaterEventsTodayInteractorImpl(waterEventsRepository: waterEventsRepository);
  final CalendarRepository calendarRepository = CalendarRepositoryImpl(
    foodEventsRepository: foodEventsRepository,
    sportEventsRepository: sportEventsRepository,
    liquidEventsRepository: liquidEventsRepository,
    waterEventsRepository: waterEventsRepository,
  );
  final GetAllEventsSortedByDateInteractor getAllEventsSortedByDateInteractor = GetAllEventsSortedByDateInteractorImpl(calendarRepository: calendarRepository);
  final FavoritesApi favoritesApi = FavoritesApi(prefsRepository, authenticationService, chuck);
  final FavoritesRepository favoritesRepository = FavoritesRepositoryImpl(localStorageRepository: localStorageRepository, favoritesApi: favoritesApi);
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor = GetFoodFavoritesInteractorImpl(favoritesRepository: favoritesRepository);
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor = SaveFoodFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor = UploadFoodFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor = RemoveFoodFavoriteFromLocalInteractorImpl(favoritesRepository: favoritesRepository);
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor = DeleteFoodFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor = UploadSportFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor = SaveSportFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final GetSportFavoritesInteractor getSportFavoritesInteractor = GetSportFavoritesInteractorImpl(favoritesRepository: favoritesRepository);
  final DeleteSportFavoriteInteractor deleteSportFavoriteInteractor = DeleteSportFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final RemoveSportFavoriteInteractor removeSportFavoriteInteractor = RemoveSportFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final RecipesApi recipesApi = RecipesApi(prefsRepository, authenticationService, chuck);
  final RecipesRepository recipesRepository = RecipesRepositoryImpl(recipesApi: recipesApi);
  final GetRecipesForFoodsInteractor getRecipesForFoodsInteractor = GetRecipesForFoodsInteractorImpl(recipesRepository: recipesRepository);
  final GetUserExclusionsInteractor getUserExclusionsInteractor = GetUserExclusionsInteractorImpl(profileRepository: profileRepository);
  final SaveLiquidFavoriteInteractor saveLiquidFavoriteInteractor = SaveLiquidFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final UploadLiquidFavoriteInteractor uploadLiquidFavoriteInteractor = UploadLiquidFavoriteInteractorImpl(favoritesRepository: favoritesRepository);
  final ExplainingCardsRepository explainingCardsRepository = ExplainingCardsRepositoryImpl(localStorageRepository: localStorageRepository);
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor = IsNecessaryToShowExplainingCardInteractorImpl(explainingCardsRepository: explainingCardsRepository);
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor = SaveExplainingCardInteractionInteractorImpl(explainingCardsRepository: explainingCardsRepository);
  final GetDayCaloriesInteractor getDayCaloriesInteractor = GetDayCaloriesInteractorImpl(sportEventsRepository: sportEventsRepository);
  final SignOutInteractor signOutInteractor = SignOutInteractorImpl(authenticationService: authenticationService);
  final EraseDatabaseInteractor eraseDatabaseInteractor = EraseDatabaseInteractorImpl(localStorageRepository: localStorageRepository);


  final dashboardBloc = DashboardBloc(
    getAdviceInteractor: getAdviceInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getUserMicronutrientsInteractor: getUserMicronutrientsInteractor,
    getUserRdasInteractor: getUserRdasInteractor,
    getProfileInteractor: getProfileInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getDayCaloriesInteractor: getDayCaloriesInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
  );

  final journalBloc = JournalBloc(
    getWeekSportsInteractor: getWeekSportsInteractor,
    getUserKcalInteractor: getUserKcalInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
  );

  final addFoodEventBloc = AddFoodEventBloc(
    getUserIdInteractor: getUserIdInteractor,
    saveFoodEventInteractor: saveFoodEventInteractor,
    uploadFoodEventInteractor: uploadFoodEventInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
  );

  final foodEventBloc = FoodBloc(
    getMasterFileInteractor: getMasterFileInteractor,
  );

  final sportEventsBloc = SportEventsBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    uploadSportsEventInteractor: uploadSportEventsInteractor,
    saveSportEventInteractor: saveSportEventInteractor,
  );

  final liquidEventBloc = LiquidEventBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    saveLiquidEventInteractor: saveLiquidEventInteractor,
    uploadLiquidEventInteractor: uploadLiquidEventInteractor,
  );

  final journalFoodBloc = JournalFoodBloc(
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getUserKcalInteractor: getUserKcalInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
  );

  final journalSportBloc = JournalSportBloc(
    getUserKcalInteractor: getUserKcalInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
  );

  final journalLiquidBloc = JournalLiquidBloc(
    getUserKcalInteractor: getUserKcalInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
  );

  final waterEventBloc = WaterEventBloc(
    getUserIdInteractor: getUserIdInteractor,
    uploadWaterEventInteractor: uploadWaterEventInteractor,
    saveWaterEventInteractor: saveWaterEventInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
  );

  final calendarBloc = CalendarBloc(
    getAllEventsSortedByDateInteractor: getAllEventsSortedByDateInteractor,
  );

  final favoriteFoodsBloc = FavoriteFoodsBloc(
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    getUserIdInteractor: getUserIdInteractor,
    removeFoodFavoriteFromLocalInteractor: removeFoodFavoriteFromLocalInteractor,
    deleteFoodFavoriteInteractor: deleteFoodFavoriteInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
  );

  final addFavoriteFoodBloc = AddFavoriteFoodBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
  );

  final createNewFoodFavoriteBloc = CreateNewFoodFavoriteBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
  );

  final addSportFavoriteBloc = AddFavoriteSportBloc(
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
  );

  final createNewSportFavoriteBloc = CreateNewSportFavoriteBloc(
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
  );

  final sportFavoritesBloc = SportFavoritesBloc(
    getSportFavoritesInteractor: getSportFavoritesInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
    getUserIdInteractor: getUserIdInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
  );

  final profileBloc = ProfileBloc(
    getProfileInteractor: getProfileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    saveProfileInteractor: saveProfileInteractor,
    uploadProfileInteractor: uploadProfileInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    signOutInteractor: signOutInteractor,
    eraseDatabaseInteractor: eraseDatabaseInteractor,
    sharedPreferences: sharedPreferences,
  );

  final addFavoriteLiquidBloc = AddFavoriteLiquidBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    saveLiquidFavoriteInteractor: saveLiquidFavoriteInteractor,
    uploadLiquidFavoriteInteractor: uploadLiquidFavoriteInteractor,
  );

  final createNewLiquidFavoriteBloc = CreateNewLiquidFavoriteBloc(
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    saveLiquidFavoriteInteractor: saveLiquidFavoriteInteractor,
    uploadLiquidFavoriteInteractor: uploadLiquidFavoriteInteractor,
  );
  final recommendationsGeneralBloc = RecommendationsGeneralBloc(
    getRecommendationInteractor: getRecommendationInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getRecipesForFoodsInteractor: getRecipesForFoodsInteractor,
    getUserExclusionsInteractor: getUserExclusionsInteractor,
  );

  runApp(
    // MultiProvider(
    MultiBlocProvider(
      providers: [
        // BlocProvider<LoginBloc>(create: (ctx) => loginBloc),
        // BlocProvider<RegistryBloc>(create: (ctx) => registryBloc),
        BlocProvider<DashboardBloc>(create: (ctx) => dashboardBloc),
        BlocProvider<JournalBloc>(create: (ctx) => journalBloc),
        BlocProvider<AddFoodEventBloc>(create: (ctx) => addFoodEventBloc),
        BlocProvider<FoodBloc>(create: (ctx) => foodEventBloc),
        BlocProvider<SportEventsBloc>(create: (ctx) => sportEventsBloc),
        BlocProvider<LiquidEventBloc>(create: (ctx) => liquidEventBloc),
        BlocProvider<JournalFoodBloc>(create: (ctx) => journalFoodBloc),
        BlocProvider<JournalSportBloc>(create: (ctx) => journalSportBloc),
        BlocProvider<JournalLiquidBloc>(create: (ctx) => journalLiquidBloc),
        BlocProvider<WaterEventBloc>(create: (ctx) => waterEventBloc),
        BlocProvider<CalendarBloc>(create: (ctx) => calendarBloc),
        BlocProvider<FavoriteFoodsBloc>(create: (ctx) => favoriteFoodsBloc),
        BlocProvider<AddFavoriteFoodBloc>(create: (ctx) => addFavoriteFoodBloc),
        BlocProvider<CreateNewFoodFavoriteBloc>(create: (ctx) => createNewFoodFavoriteBloc),
        BlocProvider<AddFavoriteSportBloc>(create: (ctx) => addSportFavoriteBloc),
        BlocProvider<CreateNewSportFavoriteBloc>(create: (ctx) => createNewSportFavoriteBloc),
        BlocProvider<SportFavoritesBloc>(create: (ctx) => sportFavoritesBloc),
        BlocProvider<ProfileBloc>(create: (ctx) => profileBloc),
        BlocProvider<AddFavoriteLiquidBloc>(create: (ctx) => addFavoriteLiquidBloc),
        BlocProvider<AddFavoriteLiquidBloc>(create: (ctx) => addFavoriteLiquidBloc),
        BlocProvider<CreateNewLiquidFavoriteBloc>(create: (ctx) => createNewLiquidFavoriteBloc),
        BlocProvider<TestBloc>(create: (ctx) => TestBloc()),
        BlocProvider<RecommendationsGeneralBloc>(create: (ctx) => recommendationsGeneralBloc),
        // ChangeNotifierProvider<SplashProvider>(create: (_) => splashProvider),
        // ChangeNotifierProvider<LoginProvider>(create: (_) => loginProvider),
        // ChangeNotifierProvider<RegistryProvider>(create: (_) => registryProvider),
        // ChangeNotifierProvider<DashboardProvider>(create: (_) => dashboardProvider),
        // ChangeNotifierProvider<AddFoodEventProvider>(create: (_) => addFoodEventProvider),
        // ChangeNotifierProvider<RecommendationsProvider>(create: (_) => recommendationsProvider),
        // ChangeNotifierProvider<AddSportEventProvider>(create: (_) => addSportEventProvider),
        // ChangeNotifierProxyProvider<ClaseDeLaQueDepende, ClaseQueSeProvee>(
        //     create: (ctx) {},
        //     update: (ctx, dynamic, objetoQueSeProvee) => ClaseQueSeProvee(),
        // ),
      ],
      child: MaterialApp(
        navigatorKey: chuck.getNavigatorKey(),
        title: 'NutreNaissance',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color.fromARGB(255, 107, 107, 107),
            secondary: const Color.fromARGB(255, 0, 0, 0),
            tertiary: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        initialRoute: '/',
        localizationsDelegates: const [
          AppLocalizationsHelperDelegate(),
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('es', ''), // Spanish, no country code
        ],
        routes: {
          '/': (_) => const SplashScreen(),
          TestScreen.routeName: (_) => const TestScreen(),
          SplashScreen.routeName: (_) => const SplashScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegistryScreen.routeName: (_) => const RegistryScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          AddFoodEventScreen.routeName: (_) => const AddFoodEventScreen(),
          AddSportEventScreen.routeName: (_) => const AddSportEventScreen(),
          AddLiquidEventScreen.routeName: (_) => const AddLiquidEventScreen(),
          JournalScreen.routeName: (_) => const JournalScreen(),
          JournalFoodScreen.routeName: (_) => const JournalFoodScreen(),
          JournalSportScreen.routeName: (_) => const JournalSportScreen(),
          JournalLiquidScreen.routeName: (_) => const JournalLiquidScreen(),
          AddWaterEventScreen.routeName: (_) => const AddWaterEventScreen(),
          CalendarScreen.routeName: (_) => const CalendarScreen(),
          FavoriteFoodsScreen.routeName: (_) => const FavoriteFoodsScreen(),
          FavoriteFoodsClusterScreen.routeName: (_) => const FavoriteFoodsClusterScreen(),
          AddFoodFavoriteScreen.routeName: (_) => const AddFoodFavoriteScreen(),
          CreateNewFoodFavoriteScreen.routeName: (_) => const CreateNewFoodFavoriteScreen(),
          AddSportFavoriteScreen.routeName: (_) => const AddSportFavoriteScreen(),
          CreateNewSportFavoriteScreen.routeName: (_) => const CreateNewSportFavoriteScreen(),
          FavoriteSportsScreen.routeName: (_) => const FavoriteSportsScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AddLiquidFavoriteScreen.routeName: (_) => const AddLiquidFavoriteScreen(),
          CreateNewLiquidFavoriteScreen.routeName: (_) => const CreateNewLiquidFavoriteScreen(),
          AversionsScreen.routeName: (_) => const AversionsScreen(),
          FoodListAversionsScreen.routeName: (_) => const FoodListAversionsScreen(),
          GeneralQuestionsScreen.routeName: (_) => const GeneralQuestionsScreen(),
          HealthQuestionsScreen.routeName: (_) => const HealthQuestionsScreen(),
          DietQuestionsScreen.routeName: (_) => const DietQuestionsScreen(),
          ObjectivesScreen.routeName: (_) => const ObjectivesScreen(),
          PhysicalActivityScreen.routeName: (_) => const PhysicalActivityScreen(),
          RecommendationsTabHolder.routeName: (_) => const RecommendationsTabHolder(),
          FoodScreen.routeName: (_) => const FoodScreen(),
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          PrivacyPolicy.routeName: (_) => const PrivacyPolicy(),
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
  Hive.registerAdapter(SportsInfoEntityAdapter());
  Hive.registerAdapter(SportInfoEntityAdapter());
  Hive.registerAdapter(SportEventEntityAdapter());
  Hive.registerAdapter(SportEventInfoEntityAdapter());
  Hive.registerAdapter(UnitsFoodsEntityAdapter());
  Hive.registerAdapter(UnitFoodEntityAdapter());
  Hive.registerAdapter(UnitsInfoEntityAdapter());
  Hive.registerAdapter(UnitInfoEntityAdapter());
  Hive.registerAdapter(UserRdasEntityAdapter());
  Hive.registerAdapter(UserRdaEntityAdapter());
  Hive.registerAdapter(LiquidEventEntityAdapter());
  Hive.registerAdapter(LiquidInfoAdapter());
  Hive.registerAdapter(LiquidParamsAdapter());
  Hive.registerAdapter(LiquidEventInfoAdapter());
  Hive.registerAdapter(WaterEventEntityAdapter());
  Hive.registerAdapter(FoodFavoriteEntityAdapter());
  Hive.registerAdapter(FoodInFavoriteEntityAdapter());
  Hive.registerAdapter(LiquidFavoriteEntityAdapter());
  Hive.registerAdapter(LiquidInFavoriteEntityAdapter());
  Hive.registerAdapter(SportFavoriteEntityAdapter());
  Hive.registerAdapter(ExplainingCardEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisListEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisTestEntityAdapter());
  Hive.registerAdapter(TestQuestionEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisResultEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisAnswerResultEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisTestAnswerResultEntityAdapter());
}