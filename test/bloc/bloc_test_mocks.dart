import 'package:mockito/annotations.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
// SupplementsBloc
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_routine_interactor.dart';
// AddFoodEventBloc
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor.dart';
// SportEventsBloc
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/upload_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/save_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
// LoginBloc
import 'package:nutrenaissance_flutter/domain/interactor/login/signup_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/send_perrification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/signin_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/resend_verification_code_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_user_credentials_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/save_user_in_users_remote_database_interactor.dart';
// JournalFoodBloc / JournalSportBloc
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/delete_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor.dart';
// RoutinesBloc
import 'package:nutrenaissance_flutter/domain/interactor/routines/delete_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/remove_sport_routine_interactor.dart';
// SupplementsDetailBloc
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
// MealTimeDetailsBloc
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
// FecesUrineBloc
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_faeces_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor.dart';
// DashboardBloc
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/save_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_today_step_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_dashboard_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/localstorage/erase_db_local_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/show_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/save_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import 'package:chuck_interceptor/chuck.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  // FoodBloc
  MockSpec<GetMasterFileInteractor>(),
  // SettingsBloc
  MockSpec<SignOutInteractor>(),
  MockSpec<EraseDatabaseInteractor>(),
  // EnergyBalanceDetailBloc
  MockSpec<GetWeekFoodEventsInteractor>(),
  MockSpec<GetWeekLiquidEventsInteractor>(),
  MockSpec<GetWeekSportsInteractor>(),
  MockSpec<GetProfileInteractor>(),
  // FavoriteFoodsBloc
  MockSpec<GetFoodFavoritesInteractor>(),
  MockSpec<GetUserIdInteractor>(),
  MockSpec<DeleteFoodFavoriteInteractor>(),
  MockSpec<RemoveFoodFavoriteFromLocalInteractor>(),
  MockSpec<IsNecessaryToShowExplainingCardInteractor>(),
  MockSpec<SaveExplainingCardInteractionInteractor>(),
  // SupplementsBloc
  MockSpec<UploadSupplementEventInteractor>(),
  MockSpec<SaveSupplementEventInteractor>(),
  MockSpec<UploadSupplementFavoriteInteractor>(),
  MockSpec<SaveSupplementFavoriteInteractor>(),
  MockSpec<GetSupplementFavoritesInteractor>(),
  MockSpec<UploadSupplementRoutineInteractor>(),
  MockSpec<SaveSupplementRoutineInteractor>(),
  // AddFoodEventBloc
  MockSpec<SaveFoodEventInteractor>(),
  MockSpec<UploadFoodEventInteractor>(),
  MockSpec<UploadFoodFavoriteInteractor>(),
  MockSpec<SaveFoodFavoriteInteractor>(),
  MockSpec<UploadFoodRoutineInteractor>(),
  MockSpec<SaveFoodRoutineInteractor>(),
  // SportEventsBloc
  MockSpec<SaveSportEventInteractor>(),
  MockSpec<UploadSportEventsInteractor>(),
  MockSpec<GetSportFavoritesInteractor>(),
  MockSpec<UploadRoutineInteractor>(),
  MockSpec<SaveRoutineInteractor>(),
  MockSpec<UploadSportFavoriteInteractor>(),
  MockSpec<SaveSportFavoriteInteractor>(),
  MockSpec<DeleteSportFavoriteInteractor>(),
  MockSpec<RemoveSportFavoriteInteractor>(),
  // LoginBloc
  MockSpec<SignUpInteractor>(),
  MockSpec<SendVerificationCodeInteractor>(),
  MockSpec<FetchUserAttributesInteractor>(),
  MockSpec<SignInInteractor>(),
  MockSpec<SaveUsernameAndEmailInteractor>(),
  MockSpec<GetMasterFileVersionInteractor>(),
  MockSpec<ManageMasterFilesInteractor>(),
  MockSpec<SaveMasterFileInteractor>(),
  MockSpec<CheckProfileExistenceInteractor>(),
  MockSpec<DownloadProfileInteractor>(),
  MockSpec<GetIdTokenInteractor>(),
  MockSpec<SaveProfileInteractor>(),
  MockSpec<ResendVerificationCodeInteractor>(),
  MockSpec<SaveUserCredentialsInteractor>(),
  MockSpec<SaveUserInUsersRemoteDatabaseInteractor>(),
  // DashboardBloc
  MockSpec<GetFoodEventsOfTodayInteractor>(),
  MockSpec<GetAdviceInteractor>(),
  MockSpec<GetWaterEventsTodayInteractor>(),
  MockSpec<GetDayCaloriesInteractor>(),
  MockSpec<GetTodayLiquidEventsInteractor>(),
  MockSpec<UploadProfileInteractor>(),
  MockSpec<UploadWaterEventInteractor>(),
  MockSpec<SaveWaterEventInteractor>(),
  MockSpec<UploadStepsInteractor>(),
  MockSpec<SaveStepsInteractor>(),
  MockSpec<GetStepsInteractor>(),
  MockSpec<GetTodayStepInteractor>(),
  MockSpec<GetAllEventsSortedByDateInteractor>(),
  MockSpec<GetAllDashboardEventsSortedByDateInteractor>(),
  MockSpec<GetTodayCreatineEventInteractor>(),
  MockSpec<UploadCreatineEventInteractor>(),
  MockSpec<SaveCreatineEventInteractor>(),
  MockSpec<GetTodayCollagenEventInteractor>(),
  MockSpec<UploadCollagenEventInteractor>(),
  MockSpec<SaveCollagenEventInteractor>(),
  MockSpec<GetRoutinesInteractor>(),
  MockSpec<EraseDBLocalEventsInteractor>(),
  MockSpec<SynchronizeEventsInteractor>(),
  MockSpec<ShowModelAppearanceInteractor>(),
  MockSpec<SaveModelAppearanceInteractor>(),
  MockSpec<GetTodaySportsInteractor>(),
  MockSpec<GetDaySupplementEventsInteractor>(),
  MockSpec<Chuck>(),
  MockSpec<SharedPreferences>(),
  // JournalFoodBloc / JournalSportBloc
  MockSpec<GetUserKcalInteractor>(),
  MockSpec<RemoveFoodEventInteractor>(),
  MockSpec<DeleteFoodEventInteractor>(),
  MockSpec<DeleteSportEventInteractor>(),
  MockSpec<RemoveSportEventInteractor>(),
  // RoutinesBloc
  MockSpec<DeleteSportRoutineInteractor>(),
  MockSpec<RemoveSportRoutineInteractor>(),
  // SupplementsDetailBloc
  MockSpec<DeleteSupplementEventInteractor>(),
  MockSpec<RemoveSupplementEventInteractor>(),
  MockSpec<UpdateEventsInteractor>(),
  // MealTimeDetailsBloc
  MockSpec<PreferencesRepository>(),
  // FecesUrineBloc
  MockSpec<GetFaecesByDateInteractor>(),
  MockSpec<GetUrineByDateInteractor>(),
  MockSpec<GetFecesEventsInteractor>(),
  MockSpec<GetUrineEventsInteractor>(),
  MockSpec<UploadFecesInteractor>(),
  MockSpec<SaveFecesEventInteractor>(),
  MockSpec<UploadUrineInteractor>(),
  MockSpec<SaveUrineInteractor>(),
  MockSpec<DeleteFecesEventInteractor>(),
  MockSpec<RemoveFecesEventInteractor>(),
  MockSpec<DeleteUrineEventInteractor>(),
  MockSpec<RemoveUrineEventInteractor>(),
])
void main() {}
