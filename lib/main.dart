import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/advices/advices_api.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/favorites_api.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/fece_urine_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/liquid_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/api/recipes/recipes_api.dart';
import 'package:nutrenaissance_flutter/data/api/recommendations/recommendations_api.dart';
import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/data/api/waterevents/water_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/explainingcards/explaining_card_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';
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
import 'package:nutrenaissance_flutter/data/local/models/recipes/recipe_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/advices/advices_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/calendar/calendar_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/explainingcards/explaining_cards_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/favorites/favorites_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/fecesurine/feces_urine_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/foodevents/food_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/liquidevents/liquid_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recipes/recipes_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recommendations/recommendations_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/routines/routines_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/sportevents/sport_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/steps/steps_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/supplements/supplements_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/waterevents/water_event_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_dashboard_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_dashboard_events_sorted_by_date_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_faeces_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_faeces_by_date_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_feces_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/delete_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/delete_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/remove_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/remove_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/localstorage/erase_db_local_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/localstorage/erase_db_local_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/recipes/delete_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/delete_recipe_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipe_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipe_favorites_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/remove_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/remove_recipe_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/save_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/save_recipe_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/upload_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/upload_recipe_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/delete_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/delete_sport_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/remove_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/remove_sport_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/save_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/save_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/upload_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/upload_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_steps_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_today_step_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_today_step_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/save_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/save_steps_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/advices/advices_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/recommendations/recommendations_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/view/calendar_screen.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/test_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/bloc/energy_balance_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/view/energy_balance_detail_screen.dart';
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
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces/view/feces_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_urine_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine/view/urine_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fiber_detail/bloc/fiber_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fiber_detail/view/fiber_detail_Screen.dart';
import 'package:nutrenaissance_flutter/presentation/food/bloc/food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/food/view/food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/view/fogotten_password_screen.dart';
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
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/bloc/liquid_summary_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/view/liquid_summary_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/view/macro_nutrients_detail.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/bloc/weekly_all_nutrients_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/view/weekly_all_nutrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/privacypolicy/privacy_policy.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/food_list_aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/registry/view/registry_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/common/bloc/recipe_tab_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/common/view/recipe_tabs_holder.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/recipe_detail/bloc/recipe_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/recipe_detail/view/recipe_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routines/view/routines_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/view/splash_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/bloc/sugar_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/view/sugar_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/bloc/weekly_dashboard_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/view/weekly_dashboard_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'data/api/eventssync/events_sync_api.dart';
import 'data/local/models/steps/steps_entity.dart';
import 'data/repository/eventssync/events_synchronization_repository_impl.dart';
import 'domain/interactor/fecesurine/get_urine_by_date_interactor.dart';
import 'domain/interactor/fecesurine/get_urine_by_date_interactor_impl.dart';
import 'domain/interactor/foodevents/delete_food_event_interactor.dart';
import 'domain/interactor/foodevents/delete_food_event_interactor_impl.dart';
import 'domain/interactor/foodevents/remove_food_event_interactor_impl.dart';
import 'domain/interactor/login/erase_database_interactor_impl.dart';
import 'domain/interactor/masterfiles/get_master_file_version_interactor_impl.dart';
import 'domain/interactor/masterfiles/manage_master_files_interactor_impl.dart';
import 'domain/interactor/profile/get_user_objectives_interactor.dart';
import 'domain/interactor/profile/get_user_objectives_interactor_impl.dart';
import 'presentation/profile/common/aversions_screen.dart';
import 'presentation/profile/common/health_questions_screen.dart';
import 'presentation/recommendations/common/view/recommendations_tabs_holder.dart';
import 'presentation/waterevent/view/add_water_event_screen.dart';

import 'package:chuck_interceptor/chuck.dart';

// @pragma('vm:entry-point')
// void printHello() {
// final DateTime now = DateTime.now();
// final int isolateId = Isolate.current.hashCode;
// print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
// ToastHelper().showToast(text: "[$now] Hello, world! isolate=$isolateId function='$printHello'");
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  const String environmentName = String.fromEnvironment(Environment.DEV, defaultValue: Environment.DEV);
  Environment().initConfig(environmentName);
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();
  await Upgrader.clearSavedSettings();

  initLocalStorage();

  final authenticationService = await CognitoAuthenticationService.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Chuck chuck = Chuck(
    showNotification: true,
    darkTheme: true,
    navigatorKey: navigatorKey,
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
  final GetUserObjectivesInteractor getUserObjectivesInteractor = GetUserObjectivesInteractorImpl(profileRepository: profileRepository);
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
  final SupplementApi supplementApi = SupplementApi(prefsRepository, authenticationService, chuck);
  final SupplementsRepository supplementsRepository = SupplementsRepositoryImpl(supplementApi: supplementApi, localStorageRepository: localStorageRepository);
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
  final RecipesRepository recipesRepository = RecipesRepositoryImpl(recipesApi: recipesApi, localStorageRepository: localStorageRepository);
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
  final RemoveFoodEventInteractor removeFoodEventInteractor = ReomveFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final DeleteFoodEventInteractor deleteFoodEventInteractor = DeleteFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final RemoveSportEventInteractor removeSportEventInteractor = RemoveSportEventInteractorImpl(sportEventsRepository: sportEventsRepository);
  final DeleteSportEventInteractor deleteSportEventInteractor = DeleteSportEventInteractorImpl(sportEventsRepository: sportEventsRepository);
  final LoginRepository loginRepository = LoginRepositoryImpl(authenticationService: authenticationService, profileApi: profileApi);
  final StepsApi stepsApi = StepsApi(prefsRepository, authenticationService, chuck);
  final StepsRepository stepsRepository = StepsRepositoryImpl(stepsApi: stepsApi, localStorageRepository: localStorageRepository);
  final UploadStepsInteractor uploadStepsInteractor = UploadStepsInteractorImpl(stepsRepository: stepsRepository);
  final SaveStepsInteractor saveStepsInteractor = SaveStepsInteractorImpl(stepsRepository: stepsRepository);
  final GetStepsInteractor getStepsInteractor = GetStepsInteractorImpl(stepsRepository: stepsRepository);
  final GetTodayStepInteractor getTodayStepInteractor = GetTodayStepInteractorImpl(stepsRepository: stepsRepository);
  final RoutinesApi routinesApi = RoutinesApi(prefsRepository, authenticationService, chuck);
  final RoutinesRepository routinesRepository = RoutinesRepositoryImpl(routinesApi: routinesApi, localStorageRepository: localStorageRepository);
  final UploadRoutineInteractor uploadRoutineInteractor = UploadRoutineInteractorImpl(routinesRepository: routinesRepository);
  final GetRoutinesInteractor getRoutinesInteractor = GetRoutinesInteractorImpl(routinesRepository: routinesRepository);
  final SaveRoutineInteractor saveRoutineInteractor = SaveRoutineInteractorImpl(routinesRepository: routinesRepository);
  final DeleteSportRoutineInteractor deleteSportRoutineInteractor = DeleteSportRoutineInteractorImpl(routinesRepository: routinesRepository);
  final RemoveSportRoutineInteractor removeSportRoutineInteractor = RemoveSportRoutineInteractorImpl(routinesRepository: routinesRepository);
  final DeleteLiquidEventInteractor deleteLiquidEventInteractor = DeleteLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final RemoveLiquidEventInteractor removeLiquidEventInteractor = RemoveLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final UploadRecipeFavoriteInteractor uploadRecipeFavoriteInteractor = UploadRecipeFavoriteInteractorImpl(recipesRepository: recipesRepository);
  final GetRecipeFavoritesInteractor getRecipeFavoritesInteractor = GetRecipeFavoritesInteractorImpl(recipesRepository: recipesRepository);
  final SaveRecipeFavoriteInteractor saveRecipeFavoriteInteractor = SaveRecipeFavoriteInteractorImpl(recipesRepository: recipesRepository);
  final DeleteRecipeFavoriteInteractor deleteRecipeFavoriteInteractor = DeleteRecipeFavoriteInteractorImpl(recipesRepository: recipesRepository);
  final RemoveRecipeFavoriteInteractor removeRecipeFavoriteInteractor = RemoveRecipeFavoriteInteractorImpl(recipesRepository: recipesRepository);
  final FecesUrineApi fecesUrineApi = FecesUrineApi(prefsRepository, authenticationService, chuck);
  final FecesUrineRepository fecesUrineRepository = FecesUrineRepositoryImpl(fecesUrineApi: fecesUrineApi, localStorageRepository: localStorageRepository);
  final UploadFecesInteractor uploadFecesInteractor = UploadFecesInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final SaveFecesEventInteractor saveFecesEventInteractor = SaveFecesEventInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final GetFecesEventsInteractor getFecesEventsInteractor = GetFecesEventsInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final GetFaecesByDateInteractor getFaecesByDateInteractor = GetFaecesByDateInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final GetUrineByDateInteractor getUrineByDateInteractor = GetUrineByDateInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final UploadUrineInteractor uploadUrineInteractor = UploadUrineInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final SaveUrineInteractor saveUrineInteractor = SaveUrineInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final GetUrineEventsInteractor getUrineEventsInteractor = GetUrineEventsInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final DeleteFecesEventInteractor deleteFecesEventInteractor = DeleteFecesEventInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final RemoveFecesEventInteractor removeFecesEventInteractor = RemoveFecesEventInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final DeleteUrineEventInteractor deleteUrineEventInteractor = DeleteUrineEventInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final RemoveUrineEventInteractor removeUrineEventInteractor = RemoveUrineEventInteractorImpl(fecesUrineRepository: fecesUrineRepository);
  final GetTodayCreatineEventInteractor getTodayCreatineEventInteractor = GetTodayCreatineEventInteractorImpl(supplementsRepository: supplementsRepository);
  final UploadCreatineEventInteractor uploadCreatineEventInteractor = UploadCreatineEventInteractorImpl(supplementsRepository: supplementsRepository);
  final SaveCreatineEventInteractor saveCreatineEventInteractor = SaveCreatineEventInteractorImpl(supplementsRepository: supplementsRepository);
  final GetTodayCollagenEventInteractor getTodayCollagenEventInteractor = GetTodayCollagenEventInteractorImpl(supplementsRepository: supplementsRepository);
  final UploadCollagenEventInteractor uploadCollagenEventInteractor = UploadCollagenEventInteractorImpl(supplementsRepository: supplementsRepository);
  final SaveCollagenEventInteractor saveCollagenEventInteractor = SaveCollagenEventInteractorImpl(supplementsRepository: supplementsRepository);
  final GetMasterFileVersionInteractor getMasterFilesVersionInteractor = GetMasterFileVersionInteractorImpl(masterFilesRepository: masterFilesRepository);
  final ManageMasterFilesInteractor manageMasterFilesInteractor = ManageMasterFilesInteractorImpl(masterFilesRepository: masterFilesRepository);
  final CalendarRepository calendarRepository = CalendarRepositoryImpl(
      foodEventsRepository: foodEventsRepository,
      sportEventsRepository: sportEventsRepository,
      liquidEventsRepository: liquidEventsRepository,
      waterEventsRepository: waterEventsRepository,
      supplementsRepository: supplementsRepository,
      fecesUrineRepository: fecesUrineRepository,
  );
  final GetAllDashboardEventsSortedByDateInteractor getAllDashboardEventsSortedByDateInteractor = GetAllDashboardEventsSortedByDateInteractorImpl(calendarRepository: calendarRepository);
  final GetAllEventsSortedByDateInteractor getAllEventsSortedByDateInteractor = GetAllEventsSortedByDateInteractorImpl(calendarRepository: calendarRepository);
  final EraseDBLocalEventsInteractor eraseDBLocalEventsInteractor = EraseDBLocalEventsInteractorImpl(localStorageRepository: localStorageRepository);
  final eventsSyncApi = EventsSyncApi(prefsRepository, authenticationService, chuck);
  final eventsSynchronizationRequestRepository = EventsSynchronizationRequestRepositoryImpl(localStorageRepository: localStorageRepository, eventsSyncApi: eventsSyncApi);
  final SynchronizeEventsInteractor synchronizeEventsInteractor = SynchronizeEventsInteractorImpl(eventsSynchronizationRequestRepository: eventsSynchronizationRequestRepository);

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
    getUserObjectivesInteractor: getUserObjectivesInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
    uploadProfileInteractor: uploadProfileInteractor,
    saveProfileInteractor: saveProfileInteractor,
    uploadWaterEventInteractor: uploadWaterEventInteractor,
    saveWaterEventInteractor: saveWaterEventInteractor,
    uploadStepsInteractor: uploadStepsInteractor,
    saveStepsInteractor: saveStepsInteractor,
    getStepsInteractor: getStepsInteractor,
    getTodayStepInteractor: getTodayStepInteractor,
    getAllEventsSortedByDateInteractor: getAllEventsSortedByDateInteractor,
    getTodayCreatineEventInteractor: getTodayCreatineEventInteractor,
    uploadCreatineEventInteractor: uploadCreatineEventInteractor,
    saveCreatineEventInteractor: saveCreatineEventInteractor,
    getTodayCollagenEventInteractor: getTodayCollagenEventInteractor,
    uploadCollagenEventInteractor: uploadCollagenEventInteractor,
    saveCollagenEventInteractor: saveCollagenEventInteractor,
    getAllDashboardEventsSortedByDateInteractor: getAllDashboardEventsSortedByDateInteractor,
    manageMasterFilesInteractor:manageMasterFilesInteractor,
    getMasterFilesVersionInteractor: getMasterFilesVersionInteractor,
    signOutInteractor: signOutInteractor,
    eraseDatabaseInteractor: eraseDatabaseInteractor,
    sharedPreferences: sharedPreferences,
    getRoutinesInteractor: getRoutinesInteractor,
    eraseDBLocalEventsInteractor: eraseDBLocalEventsInteractor,
    synchronizeEventsInteractor: synchronizeEventsInteractor,
    chuck: chuck,
  );

  final micronutrientsDetailBloc = MicroNutrientsDetailBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserMicronutrientsInteractor: getUserMicronutrientsInteractor,
    getUserRdasInteractor: getUserRdasInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getProfileInteractor: getProfileInteractor,
  );

  final macronutrientsDetailBloc = MacroNutrientsDetailBloc(
    getProfileInteractor: getProfileInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
  );

  final energyBalanceDetailBloc = EnergyBalanceDetailBloc(
    getProfileInteractor: getProfileInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
  );

  final sugarDetailBloc = SugarDetailBloc();

  final fiberDetailBloc = FiberDetailBloc();

  final weeklyAllNutrientsBloc = WeeklyAllNutrientsBloc();

  final liquidSummaryDetailBloc = LiquidSummaryDetailBloc(
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getProfileInteractor: getProfileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    uploadWaterEventInteractor: uploadWaterEventInteractor,
    saveWaterEventInteractor: saveWaterEventInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
  );

  final forgottenPasswordBloc = ForgottenPasswordBloc(loginRepository: loginRepository);

  final resetPasswordBloc = ResetPasswordBloc(loginRepository: loginRepository);

  final weeklyDashboardDetailBloc = WeeklyDashboardDetailBloc(
    getProfileInteractor: getProfileInteractor,
    getUserRdasInteractor: getUserRdasInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getUserMicronutrientsInteractor: getUserMicronutrientsInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
  );

  final journalBloc = JournalBloc(
    getWeekSportsInteractor: getWeekSportsInteractor,
    getUserKcalInteractor: getUserKcalInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getProfileInteractor: getProfileInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
  );

  final addFoodEventBloc = AddFoodEventBloc(
    getUserIdInteractor: getUserIdInteractor,
    saveFoodEventInteractor: saveFoodEventInteractor,
    uploadFoodEventInteractor: uploadFoodEventInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
  );

  final foodEventBloc = FoodBloc(
    getMasterFileInteractor: getMasterFileInteractor,
  );

  final sportEventsBloc = SportEventsBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    uploadSportsEventInteractor: uploadSportEventsInteractor,
    saveSportEventInteractor: saveSportEventInteractor,
    getSportFavoritesInteractor: getSportFavoritesInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
    uploadRoutineInteractor: uploadRoutineInteractor,
    saveRoutineInteractor: saveRoutineInteractor,
  );

  final liquidEventBloc = LiquidEventBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    saveLiquidEventInteractor: saveLiquidEventInteractor,
    uploadLiquidEventInteractor: uploadLiquidEventInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
  );

  final journalFoodBloc = JournalFoodBloc(
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getUserKcalInteractor: getUserKcalInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
    removeFoodFavoriteFromLocalInteractor: removeFoodFavoriteFromLocalInteractor,
    deleteFoodFavoriteInteractor: deleteFoodFavoriteInteractor,
    getUserIdInteractor: getUserIdInteractor,
    deleteFoodEventInteractor: deleteFoodEventInteractor,
    removeFoodEventInteractor: removeFoodEventInteractor,
  );

  final journalSportBloc = JournalSportBloc(
    getUserKcalInteractor: getUserKcalInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getWeekSportsInteractor: getWeekSportsInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getSportFavoritesInteractor: getSportFavoritesInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
    getUserIdInteractor: getUserIdInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
    deleteSportEventInteractor: deleteSportEventInteractor,
    removeSportEventInteractor: removeSportEventInteractor,
    eraseDBLocalEventsInteractor: eraseDBLocalEventsInteractor,
    synchronizeEventsInteractor: synchronizeEventsInteractor,
  );

  final routineBloc = RoutinesBloc(
    getRoutinesInteractor: getRoutinesInteractor,
    getUserIdInteractor: getUserIdInteractor,
    deleteSportRoutineInteractor: deleteSportRoutineInteractor,
    removeSportRoutineInteractor: removeSportRoutineInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
    getSportFavoritesInteractor: getSportFavoritesInteractor,
  );

  final journalLiquidBloc = JournalLiquidBloc(
    getUserKcalInteractor: getUserKcalInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getWeekLiquidEventsInteractor: getWeekLiquidEventsInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
    getProfileInteractor: getProfileInteractor,
    deleteLiquidEventInteractor: deleteLiquidEventInteractor,
    removeLiquidEventInteractor: removeLiquidEventInteractor,
    getUserIdInteractor: getUserIdInteractor,
  );

  final waterEventBloc = WaterEventBloc(
    getUserIdInteractor: getUserIdInteractor,
    uploadWaterEventInteractor: uploadWaterEventInteractor,
    saveWaterEventInteractor: saveWaterEventInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
  );

  final calendarBloc = CalendarBloc(
    getAllEventsSortedByDateInteractor: getAllEventsSortedByDateInteractor,
    getUserIdInteractor: getUserIdInteractor,
    removeFoodEventInteractor: removeFoodEventInteractor,
    deleteFoodEventInteractor: deleteFoodEventInteractor,
    removeSportEventInteractor: removeSportEventInteractor,
    deleteSportEventInteractor: deleteSportEventInteractor,
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
    uploadFoodEventInteractor: uploadFoodEventInteractor,
    saveFoodEventInteractor: saveFoodEventInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    deleteFoodFavoriteInteractor: deleteFoodFavoriteInteractor,
    removeFoodFavoriteFromLocalInteractor: removeFoodFavoriteFromLocalInteractor,
  );

  final createNewFoodFavoriteBloc = CreateNewFoodFavoriteBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
  );

  final addSportFavoriteBloc = AddFavoriteSportBloc(
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
    getSportFavoritesInteractor: getSportFavoritesInteractor,
    uploadSportsEventInteractor: uploadSportEventsInteractor,
    saveSportEventInteractor: saveSportEventInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
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

  final fecesUrineBloc = FecesUrineBloc(
    getUserIdInteractor: getUserIdInteractor,
    uploadFecesInteractor: uploadFecesInteractor,
    getFecesEventsInteractor: getFecesEventsInteractor,
    saveFecesEventInteractor: saveFecesEventInteractor,
    getUrineEventsInteractor: getUrineEventsInteractor,
    saveUrineInteractor: saveUrineInteractor,
    uploadUrineInteractor: uploadUrineInteractor,
    deleteFecesEventInteractor: deleteFecesEventInteractor,
    removeFecesEventInteractor: removeFecesEventInteractor,
    deleteUrineEventInteractor: deleteUrineEventInteractor,
    removeUrineEventInteractor: removeUrineEventInteractor,
    getFaecesByDateInteractor: getFaecesByDateInteractor,
    getUrineByDateInteractor: getUrineByDateInteractor,
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
    getProfileInteractor: getProfileInteractor,
    uploadProfileInteractor: uploadProfileInteractor,
    saveProfileInteractor: saveProfileInteractor,
  );

  final recipeTabBloc = RecipeTabBloc(
      getUserIdInteractor: getUserIdInteractor,
      getProfileInteractor: getProfileInteractor,
      getRecipesForFoodsInteractor: getRecipesForFoodsInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    uploadRecipeFavoriteInteractor: uploadRecipeFavoriteInteractor,
    getRecipeFavoritesInteractor: getRecipeFavoritesInteractor,
    saveRecipeFavoriteInteractor: saveRecipeFavoriteInteractor,
    deleteRecipeFavoriteInteractor: deleteRecipeFavoriteInteractor,
    removeRecipeFavoriteInteractor: removeRecipeFavoriteInteractor,
  );

  final recipeDetailBloc = RecipeDetailBloc(
    getMasterFileInteractor: getMasterFileInteractor,
  );

  // await AndroidAlarmManager.periodic(const Duration(seconds: 5), 0, printHello);

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
        BlocProvider<MicroNutrientsDetailBloc>(create: (ctx) => micronutrientsDetailBloc),
        BlocProvider<MacroNutrientsDetailBloc>(create: (ctx) => macronutrientsDetailBloc),
        BlocProvider<EnergyBalanceDetailBloc>(create: (ctx) => energyBalanceDetailBloc),
        BlocProvider<SugarDetailBloc>(create: (ctx) => sugarDetailBloc),
        BlocProvider<FiberDetailBloc>(create: (ctx) => fiberDetailBloc),
        BlocProvider<LiquidSummaryDetailBloc>(create: (ctx) => liquidSummaryDetailBloc),
        BlocProvider<WeeklyDashboardDetailBloc>(create: (ctx) => weeklyDashboardDetailBloc),
        BlocProvider<ForgottenPasswordBloc>(create: (ctx) => forgottenPasswordBloc),
        BlocProvider<ResetPasswordBloc>(create: (ctx) => resetPasswordBloc),
        BlocProvider<FecesUrineBloc>(create: (ctx) => fecesUrineBloc),
        BlocProvider<RoutinesBloc>(create: (context) => routineBloc,),
        BlocProvider<WeeklyAllNutrientsBloc>(create: (context) => weeklyAllNutrientsBloc,),
        BlocProvider<RecipeTabBloc>(create: (context) => recipeTabBloc,),
        BlocProvider<RecipeDetailBloc>(create: (context) => recipeDetailBloc,),
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
        navigatorKey: navigatorKey,
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
          MicroNutrientsDetailScreen.routeName: (_) => const MicroNutrientsDetailScreen(),
          MacroNutrientsDetailScreen.routeName: (_) => const MacroNutrientsDetailScreen(),
          EnergyBalanceDetailScreen.routeName: (_) => const EnergyBalanceDetailScreen(),
          SugarDetailScreen.routeName: (_) => const SugarDetailScreen(),
          FiberDetailScreen.routeName: (_) => const FiberDetailScreen(),
          LiquidSummaryDetailScreen.routeName: (_) => const LiquidSummaryDetailScreen(),
          WeeklyDashboardDetailScreen.routeName: (_) => const WeeklyDashboardDetailScreen(),
          RecipesTabsHolder.routeName: (_) => const RecipesTabsHolder(),
          ForgottenPasswordScreen.routeName: (_) => const ForgottenPasswordScreen(),
          ResetPasswordScreen.routeName: (_) => const ResetPasswordScreen(),
          FecesUrineTabHolder.routeName: (_) => const FecesUrineTabHolder(),
          RoutinesScreen.routeName: (_) => const RoutinesScreen(),
          WeeklyAllNutrientsDetailScreen.routeName: (_) => const WeeklyAllNutrientsDetailScreen(),
          RecipeDetailScreen.routeName:(_) => const RecipeDetailScreen(),
          FecesScreen.routeName:(_) => const FecesScreen(),
          UrineScreen.routeName:(_) => const UrineScreen(),
        },
      ),
    ),
  );

  // Ensure Chuck is initialized in the app lifecycle
  chuck.showInspector();
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
  Hive.registerAdapter(SportFavoriteInfoEntityAdapter());
  Hive.registerAdapter(ExplainingCardEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisListEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisTestEntityAdapter());
  Hive.registerAdapter(TestQuestionEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisResultEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisAnswerResultEntityAdapter());
  Hive.registerAdapter(SubjectiveAnalysisTestAnswerResultEntityAdapter());
  Hive.registerAdapter(StepsEntityAdapter());
  Hive.registerAdapter(SportRoutineEntityAdapter());
  Hive.registerAdapter(SportRoutineInfoEntityAdapter());
  Hive.registerAdapter(RecipeFavoriteEntityAdapter());
  Hive.registerAdapter(RecipeMasterEntityAdapter());
  Hive.registerAdapter(RecipeIngredientEntityAdapter());
  Hive.registerAdapter(RecipeStepsEntityAdapter());
  Hive.registerAdapter(RecipeStepEntityAdapter());
  Hive.registerAdapter(UploadFecesEventEntityAdapter());
  Hive.registerAdapter(UploadSupplementEventEntityAdapter());
}