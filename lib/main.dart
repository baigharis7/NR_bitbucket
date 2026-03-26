import 'dart:convert';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nutrenaissance_flutter/data/api/fcm/fcm_api.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/advices/advices_api.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/favorites_api.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/fece_urine_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodroutines/food_routines_api.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/liquid_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/referencedata/reference_data_api.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/api/recipes/recipes_api.dart';
import 'package:nutrenaissance_flutter/data/api/recommendations/recommendations_api.dart';
import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/data/api/waterevents/water_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/claude_vision_provider.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/open_food_facts_barcode_provider.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository_impl.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/food_fuzzy_matcher.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_bloc.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/explainingcards/explaining_card_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodroutines/food_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/liquidevents/liquid_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_oils_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/oil_types_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/supplements_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/modelsappearence/models_appearance_entity.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_calculation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/recommendation_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sport_kcal_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/data/local/models/recipes/recipe_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/supplement_events_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/advices/advices_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/calendar/calendar_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/explainingcards/explaining_cards_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/favorites/favorites_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/fecesurine/feces_urine_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/foodevents/food_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/foodroutines/food_routines_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/liquidevents/liquid_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/login/login_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/modelsappearance/models_appearance_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recipes/recipes_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/recommendations/recommendations_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/routines/routines_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/sportevents/sport_events_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/healthsync/health_sync_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/sleep_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sleepevents/sleep_event_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/health_sync_background_service.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_items_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/delete_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/delete_food_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/get_food_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/get_food_routines_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/remove_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/remove_food_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/save_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/save_model_appearance_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/show_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/show_model_appearance_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_recent_sport_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_recent_sport_items_interactor_impl.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_day_supplement_events_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_routines_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_recent_supplement_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_recent_supplement_items_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_favorite_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/advices/advices_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/login/login_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/modelsappearance/models_appearance_repository.dart';
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
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/barcodedetail/view/bar_code_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/barcodescanning/view/bar_code_scanning_screen.dart';
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
import 'package:nutrenaissance_flutter/presentation/favoritestabs/bloc/favorites_tabs_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/favorites_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces/view/feces_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_urine_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine/view/urine_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurinedetails/view/feces_urine_tabs.dart';
import 'package:nutrenaissance_flutter/presentation/fiber_detail/bloc/fiber_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fiber_detail/view/fiber_detail_Screen.dart';
import 'package:nutrenaissance_flutter/presentation/food/bloc/food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/food/view/food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/view/fogotten_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/itemupdate/bloc/item_update_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/itemupdate/view/item_update_screen.dart';
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
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/view/meal_time_details_screen.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimeitem/view/meal_time_item_screen.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/view/micro_nurtrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrientsweekly/bloc/micro_nutrients_weekly_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrientsweekly/view/micro_nutrients_weekly_screen.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/bloc/weekly_all_nutrients_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/nutrients_detail/view/weekly_all_nutrients_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/privacy/view/policy_screen.dart';
import 'package:nutrenaissance_flutter/presentation/privacypolicy/privacy_policy.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_profile_screen.dart';
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
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routines/view/routines_screen.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/bloc/routines_tab_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/routines_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/settings/bloc/settings_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/settings/view/settings_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_onboarding_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_settings_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/view/splash_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/view/sport_items_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportupdate/bloc/sport_update_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportupdate/view/sport_update_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/bloc/sugar_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sugar_detail/view/sugar_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/bloc/supplements_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/view/supplements_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatemeal/bloc/update_meal_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/updatemeal/view/update_meal_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/bloc/update_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/view/update_sport_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/bloc/update_supplement_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/view/update_supplement_screen.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/bloc/weekly_dashboard_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/view/weekly_dashboard_detail_screen.dart';
import 'package:nutrenaissance_flutter/presentation/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'domain/interactor/supplements/get_supplement_favorites_interactor_impl.dart';
import 'domain/interactor/supplements/get_supplement_routines_interactor.dart';
import 'domain/interactor/supplements/remove_supplement_routine_interactor.dart';
import 'domain/interactor/supplements/remove_supplement_routine_interactor_impl.dart';
import 'domain/interactor/supplements/save_supplement_routine_interactor.dart';
import 'firebase_options.dart';
import 'presentation/profile/common/health_questions_screen.dart';
import 'presentation/recommendations/common/view/recommendations_tabs_holder.dart';
import 'presentation/waterevent/view/add_water_event_screen.dart';

import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:firebase_core/firebase_core.dart';

// @pragma('vm:entry-point')
// void printHello() {
// final DateTime now = DateTime.now();
// final int isolateId = Isolate.current.hashCode;
// print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
// ToastHelper().showToast(text: "[$now] Hello, world! isolate=$isolateId function='$printHello'");
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op: lifecycle sync handles data refresh on app resume
}

void main() async {
  const String environmentName = String.fromEnvironment(Environment.PROD, defaultValue: Environment.PROD);
  Environment().initConfig(environmentName);
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await AndroidAlarmManager.initialize();

  initLocalStorage();
  final ReferenceDatabase referenceDatabase = await openReferenceDatabase();
  final NutrientCalculationService nutrientCalculationService = NutrientCalculationService(referenceDatabase);
  final SportKcalCalculationService sportKcalCalculationService = SportKcalCalculationService(referenceDatabase);
  final ReferenceDataService referenceDataService = ReferenceDataService(referenceDatabase);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FcmService.instance.init();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final authenticationService = await _initAmplifyWithRetry();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Chuck chuck = Chuck(
    showNotification: true,
    darkTheme: true,
    navigatorKey: navigatorKey,
  );
  final Preferences prefs = PreferencesImpl(sharedPreferences);
  final PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
  final ReferenceDataApi referenceDataApi = ReferenceDataApi(prefsRepository, authenticationService, chuck);
  // Fetch reference data in the background (nutrients, nutrient loss, sport METs)
  _fetchReferenceData(referenceDataApi, referenceDataService);
  final syncQueueBox = await Hive.openBox<SyncQueueEntry>('syncQueue');
  await Hive.openBox<ScannedFoodEntity>(ScannedFoodEntity.boxName);
  final SyncQueueService syncQueueService = SyncQueueService(prefsRepository, authenticationService, chuck, syncQueueBox);
  // Retry any pending API calls from previous sessions
  syncQueueService.processQueue();
  final ProfileApi profileApi = ProfileApi(prefsRepository, authenticationService, chuck);
  final LocalStorageRepository localStorageRepository = LocalStorageImpl();
  final SleepEventsApi sleepEventsApi = SleepEventsApi(prefsRepository, authenticationService, chuck);
  final StepsApi stepsApiForHealthSync = StepsApi(prefsRepository, authenticationService, chuck);
  final healthSyncRepository = HealthSyncRepositoryImpl(
    localStorageRepository: localStorageRepository,
    preferencesRepository: prefsRepository,
    sleepEventsApi: sleepEventsApi,
    stepsApi: stepsApiForHealthSync,
    syncQueue: syncQueueService,
  );
  final ProfileComputationService profileComputationService = ProfileComputationService(referenceDatabase);
  final ProfileRepository profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository, profileComputationService: profileComputationService, syncQueue: syncQueueService);
  final GetUserIdInteractor getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
  final UploadProfileInteractor uploadProfileInteractor = UploadProfileInteractorImpl(profileRepository: profileRepository);
  final SaveProfileInteractor saveProfileInteractor = SaveProfileInteractorImpl(profileRepository: profileRepository);
  final FoodEventsApi foodEventsApi = FoodEventsApi(prefsRepository, authenticationService, chuck);
  final FoodEventsRepository foodEventsRepository = FoodEventsRepositoryImpl(localStorageRepository: localStorageRepository, foodEventsApi: foodEventsApi, nutrientCalculationService: nutrientCalculationService, syncQueue: syncQueueService,);
  final UploadFoodEventInteractor uploadFoodEventInteractor = UploadFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final SaveFoodEventInteractor saveFoodEventInteractor = SaveFoodEventInteractorImpl(foodEventsRepository: foodEventsRepository);
  final FoodRoutinesApi foodRoutinesApi = FoodRoutinesApi(prefsRepository, authenticationService, chuck);
  final FoodRoutinesRepository foodRoutinesRepository = FoodRoutinesRepositoryImpl(foodRoutinesApi: foodRoutinesApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService);
  final UploadFoodRoutineInteractor uploadFoodRoutineInteractor = UploadFoodRoutineInteractorImpl(foodRoutinesRepository: foodRoutinesRepository);
  final SaveFoodRoutineInteractor saveFoodRoutineInteractor = SaveFoodRoutineInteractorImpl(foodRoutinesRepository: foodRoutinesRepository);
  final GetFoodRoutinesInteractor getFoodRoutinesInteractor = GetFoodRoutinesInteractorImpl(foodRoutinesRepository: foodRoutinesRepository);
  final RemoveFoodRoutineInteractor removeFoodRoutineInteractor = RemoveFoodRoutineInteractorImpl(foodRoutinesRepository: foodRoutinesRepository);
  final DeleteFoodRoutineInteractor deleteFoodRoutineInteractor = DeleteFoodRoutineInteractorImpl(foodRoutinesRepository: foodRoutinesRepository);
  final RecommendationsApi recommendationsApi = RecommendationsApi(prefsRepository, authenticationService, chuck);
  final RecommendationsRepository recommendationsRepository = RecommendationsRepositoryImpl(recommendationsApi: recommendationsApi);
  final GetRecommendationInteractor getRecommendationInteractor = GetRecommendationInteractorImpl(recommendationsRepository: recommendationsRepository);
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor = GetUserMicronutrientsInteractorImpl(profileRepository: profileRepository);
  final GetUserObjectivesInteractor getUserObjectivesInteractor = GetUserObjectivesInteractorImpl(profileRepository: profileRepository);
  final MasterFilesApi masterFilesApi = MasterFilesApi(prefsRepository, authenticationService, chuck);
  final MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(localStorageRepository: localStorageRepository, masterFilesApi: masterFilesApi, referenceDatabase: referenceDatabase,);
  final GetMasterFileInteractor getMasterFileInteractor = GetMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);
  final GetUserRdasInteractor getUserRdasInteractor = GetUserRdasInteractorImpl(localStorageRepository: localStorageRepository);
  final SportEventsApi sportEventsApi = SportEventsApi(prefsRepository, authenticationService, chuck);
  final SportEventsRepository sportEventsRepository = SportEventsRepositoryImpl(sportEventsApi: sportEventsApi, localStorageRepository: localStorageRepository, sportKcalCalculationService: sportKcalCalculationService, syncQueue: syncQueueService,);
  final UploadSportEventsInteractor uploadSportEventsInteractor = UploadSportEventsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final SaveSportEventInteractor saveSportEventInteractor = SaveSportEventInteractorImpl(sportEventsRepository: sportEventsRepository);
  final AdvicesApi advicesApi = AdvicesApi(prefsRepository, authenticationService, chuck);
  final AdvicesRepository advicesRepository = AdvicesRepositoryImpl(advicesApi: advicesApi);
  final GetAdviceInteractor getAdviceInteractor = GetAdviceInteractorImpl(advicesRepository: advicesRepository);
  final GetProfileInteractor getProfileInteractor = GetProfileInteractorImpl(profileRepository: profileRepository);
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor = GetFoodEventsOfTodayInteractorImpl(foodEventsRepository: foodEventsRepository);
  final LiquidEventsApi liquidEventsApi = LiquidEventsApi(prefsRepository, authenticationService, chuck);
  final LiquidEventsRepository liquidEventsRepository = LiquidEventsRepositoryImpl(liquidEventsApi: liquidEventsApi, localStorageRepository: localStorageRepository, nutrientCalculationService: nutrientCalculationService, syncQueue: syncQueueService,);
  final SaveLiquidEventInteractor saveLiquidEventInteractor = SaveLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final UploadLiquidEventInteractor uploadLiquidEventInteractor = UploadLiquidEventInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor = GetWeekFoodEventsInteractorImpl(foodEventsRepository: foodEventsRepository);
  final GetRecentFoodItemsInteractor getRecentFoodItemsInteractor = GetRecentFoodItemsInteractorImpl(foodEventsRepository: foodEventsRepository);
  final GetRecentFoodEventsInteractor getRecentFoodEventsInteractor = GetRecentFoodEventsInteractorImpl(foodEventsRepository: foodEventsRepository);
  final GetUserKcalInteractor getUserKcalInteractor = GetUserKcalInteractorImpl(profileRepository: profileRepository);
  final GetTodaySportsInteractor getTodaySportsInteractor = GetTodaySportsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final GetWeekSportsInteractor getWeekSportsInteractor = GetWeekSportsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final GetRecentSportItemsInteractor getRecentSportItemsInteractor = GetRecentSportItemsInteractorImpl(sportEventsRepository: sportEventsRepository);
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor = GetWeekLiquidEventsInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final GetTodayLiquidEventsInteractor getTodayLiquidEventsInteractor = GetTodayLiquidEventsInteractorImpl(liquidEventsRepository: liquidEventsRepository);
  final WaterEventsApi waterEventsApi = WaterEventsApi(prefsRepository, authenticationService, chuck);
  final WaterEventsRepository waterEventsRepository = WaterEventRepositoryImpl(localStorageRepository: localStorageRepository, waterEventsApi: waterEventsApi, syncQueue: syncQueueService,);
  final UploadWaterEventInteractor uploadWaterEventInteractor = UploadWaterEventInteractorImpl(waterEventsRepository: waterEventsRepository);
  final SaveWaterEventInteractor saveWaterEventInteractor = SaveWaterEventInteractorImpl(waterEventsRepository: waterEventsRepository);
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor = GetWaterEventsTodayInteractorImpl(waterEventsRepository: waterEventsRepository);
  final SupplementApi supplementApi = SupplementApi(prefsRepository, authenticationService, chuck);
  final SupplementsRepository supplementsRepository = SupplementsRepositoryImpl(supplementApi: supplementApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService,);
  final FavoritesApi favoritesApi = FavoritesApi(prefsRepository, authenticationService, chuck);
  final FavoritesRepository favoritesRepository = FavoritesRepositoryImpl(localStorageRepository: localStorageRepository, favoritesApi: favoritesApi, syncQueue: syncQueueService);
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
  final RecipesRepository recipesRepository = RecipesRepositoryImpl(recipesApi: recipesApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService);
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
  final LoginRepository loginRepository = LoginRepositoryImpl(authenticationService: authenticationService, profileApi: profileApi, syncQueue: syncQueueService);
  final FcmApi fcmApi = FcmApi(prefsRepository, authenticationService, chuck);
  final StepsApi stepsApi = StepsApi(prefsRepository, authenticationService, chuck);
  final StepsRepository stepsRepository = StepsRepositoryImpl(stepsApi: stepsApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService);
  final UploadStepsInteractor uploadStepsInteractor = UploadStepsInteractorImpl(stepsRepository: stepsRepository);
  final SaveStepsInteractor saveStepsInteractor = SaveStepsInteractorImpl(stepsRepository: stepsRepository);
  final GetStepsInteractor getStepsInteractor = GetStepsInteractorImpl(stepsRepository: stepsRepository);
  final GetTodayStepInteractor getTodayStepInteractor = GetTodayStepInteractorImpl(stepsRepository: stepsRepository);
  final RoutinesApi routinesApi = RoutinesApi(prefsRepository, authenticationService, chuck);
  final RoutinesRepository routinesRepository = RoutinesRepositoryImpl(routinesApi: routinesApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService);
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
  final FecesUrineRepository fecesUrineRepository = FecesUrineRepositoryImpl(fecesUrineApi: fecesUrineApi, localStorageRepository: localStorageRepository, syncQueue: syncQueueService,);
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
  final ModelsAppearanceRepository modelsAppearanceRepository = ModelsAppearanceRepositoryImpl(localStorageRepository: localStorageRepository);
  final ShowModelAppearanceInteractor showModelAppearanceInteractor = ShowModelAppearanceInteractorImpl(modelsAppearanceRepository: modelsAppearanceRepository);
  final SaveModelAppearanceInteractor saveModelAppearanceInteractor = SaveModelAppearanceInteractorImpl(modelsAppearanceRepository: modelsAppearanceRepository);
  final UploadSupplementEventInteractor uploadSupplementEventInteractor = UploadSupplementEventInteractorImpl(supplementsRepository: supplementsRepository);
  final GetDaySupplementEventsInteractor getDaySupplementEventsInteractor = GetDaySupplementEventsInteractorImpl(supplementsRepository: supplementsRepository);
  final SaveSupplementEventInteractor saveSupplementEventInteractor = SaveSupplementInteractorImpl(supplementsRepository: supplementsRepository);
  final DeleteSupplementEventInteractor deleteSupplementEventInteractor = DeleteSupplementEventInteractorImpl(supplementsRepository: supplementsRepository);
  final RemoveSupplementEventInteractor removeSupplementEventInteractor = RemoveSupplementEventInteractorImpl(supplementsRepository: supplementsRepository);
  final UploadSupplementFavoriteInteractor uploadSupplementFavoriteInteractor = UploadSupplementFavoriteInteractorImpl(supplementsRepository: supplementsRepository);
  final SaveSupplementFavoriteInteractor saveSupplementFavoriteInteractor = SaveSupplementFavoriteInteractorImpl(supplementsRepository: supplementsRepository);
  final GetSupplementFavoritesInteractor getSupplementFavoritesInteractor = GetSupplementFavoritesInteractorImpl(supplementsRepository: supplementsRepository);
  final GetRecentSupplementItemsInteractor getRecentSupplementItemsInteractor = GetRecentSupplementItemsInteractorImpl(supplementsRepository: supplementsRepository);
  final UploadSupplementRoutineInteractor uploadSupplementRoutineInteractor = UploadSupplementRoutineInteractorImpl(supplementsRepository: supplementsRepository);
  final SaveSupplementRoutineInteractor saveSupplementRoutineInteractor = SaveSupplementRoutineInteractorImpl(supplementsRepository: supplementsRepository);
  final GetSupplementRoutinesInteractor getSupplementRoutinesInteractor = GetSupplementRoutinesIntractorImpl(supplementsRepository: supplementsRepository);
  final DeleteSupplementRoutineInteractor deleteSupplementRoutineInteractor = DeleteSupplementRoutineInteractorImpl(supplementsRepository: supplementsRepository);
  final RemoveSupplementRoutineInteractor removeSupplementRoutineInteractor = RemoveSupplementRoutineInteractorImpl(supplementsRepository: supplementsRepository);
  final DeleteSupplementFavoriteInteractor deleteSupplementFavoriteInteractor = DeleteSupplementFavoriteInteractorImpl(supplementsRepository: supplementsRepository);
  final RemoveSupplementFavoriteInteractor removeSupplementFavoriteInteractor = RemoveSupplementFavoriteInteractorImpl(supplementsRepository: supplementsRepository);
  final UpdateEventsInteractor updateEventsInteractor = UpdateEventsInteractorImpl(eventsSynchronizationRequestRepository: eventsSynchronizationRequestRepository);

  FcmService.instance.configureSyncHandler(
    getUserIdInteractor: getUserIdInteractor,
    updateEventsInteractor: updateEventsInteractor,
    synchronizeEventsInteractor: synchronizeEventsInteractor,
  );

  await NutritionUtils(getMasterFileInteractor: getMasterFileInteractor).init();

  final dashboardBloc = DashboardBloc(
    getAdviceInteractor: getAdviceInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getProfileInteractor: getProfileInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getDayCaloriesInteractor: getDayCaloriesInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
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
    updateEventsInteractor: updateEventsInteractor,
    chuck: chuck,
    showModelAppearanceInteractor: showModelAppearanceInteractor,
    saveModelAppearanceInteractor: saveModelAppearanceInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getDaySupplementEventsInteractor: getDaySupplementEventsInteractor,
    fcmApi: fcmApi,
  );

  final micronutrientsDetailBloc = MicroNutrientsDetailBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getProfileInteractor: getProfileInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
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

  final weeklyAllNutrientsBloc = WeeklyAllNutrientsBloc(
    getProfileInteractor: getProfileInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
  );

  final liquidSummaryDetailBloc = LiquidSummaryDetailBloc(
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getProfileInteractor: getProfileInteractor,
    getUserIdInteractor: getUserIdInteractor,
    uploadWaterEventInteractor: uploadWaterEventInteractor,
    saveWaterEventInteractor: saveWaterEventInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getWaterEventsTodayInteractor: getWaterEventsTodayInteractor,
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

  // -- Food Scanner --
  final ScannedFoodRepository scannedFoodRepository =
      ScannedFoodRepositoryImpl(referenceDatabase);

  final addFoodEventBloc = AddFoodEventBloc(
    getUserIdInteractor: getUserIdInteractor,
    saveFoodEventInteractor: saveFoodEventInteractor,
    uploadFoodEventInteractor: uploadFoodEventInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
    saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
    uploadFoodRoutineInteractor: uploadFoodRoutineInteractor,
    saveFoodRoutineInteractor: saveFoodRoutineInteractor,
    deleteFoodFavoriteInteractor: deleteFoodFavoriteInteractor,
    removeFoodFavoriteFromLocalInteractor: removeFoodFavoriteFromLocalInteractor,
    getRecentFoodItemsInteractor: getRecentFoodItemsInteractor,
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
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
    getRecentSportItemsInteractor: getRecentSportItemsInteractor,
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
    healthSyncRepository: healthSyncRepository,
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
  final recommendationComputationService = RecommendationComputationService(referenceDatabase);
  final recommendationsGeneralBloc = RecommendationsGeneralBloc(
    getRecommendationInteractor: getRecommendationInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    isNecessaryToShowExplainingCardInteractor: isNecessaryToShowExplainingCardInteractor,
    saveExplainingCardInteractionInteractor: saveExplainingCardInteractionInteractor,
    getRecipesForFoodsInteractor: getRecipesForFoodsInteractor,
    getUserExclusionsInteractor: getUserExclusionsInteractor,
    getProfileInteractor: getProfileInteractor,
    saveProfileInteractor: saveProfileInteractor,
    recommendationComputationService: recommendationComputationService,
    getWeekFoodEventsInteractor: getWeekFoodEventsInteractor,
    getRecentFoodEventsInteractor: getRecentFoodEventsInteractor,
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
  );
  // Pre-load recommendations data in background so Tips tab is instant
  recommendationsGeneralBloc.add(InitialStateAction());

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

  final microNutrientsWeeklyBloc = MicroNutrientsWeeklyBloc();

  final mealTimeDetailsBloc = MealTimeDetailsBloc(
    getUserIdInteractor: getUserIdInteractor,
    getFoodEventsOfTodayInteractor: getFoodEventsOfTodayInteractor,
    getLiquidEventsOfTodayInteractor: getTodayLiquidEventsInteractor,
    getProfileInteractor: getProfileInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    deleteFoodEventInteractor: deleteFoodEventInteractor,
    removeFoodEventInteractor: removeFoodEventInteractor,
    updateEventsInteractor: updateEventsInteractor,
    preferencesRepository: prefsRepository,
    profileComputationService: profileComputationService,
  );

  final favoritesTabsBloc = FavoritesTabsBloc(
    getFoodFavoritesInteractor: getFoodFavoritesInteractor,
    deleteFoodFavoriteInteractor: deleteFoodFavoriteInteractor,
    removeFoodFavoriteFromLocalInteractor: removeFoodFavoriteFromLocalInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getSportFavoritesInteractor: getSportFavoritesInteractor,
    getSupplementFavoritesInteractor: getSupplementFavoritesInteractor,
    deleteSportFavoriteInteractor: deleteSportFavoriteInteractor,
    removeSportFavoriteInteractor: removeSportFavoriteInteractor,
    deleteSupplementFavoriteInteractor: deleteSupplementFavoriteInteractor,
    removeSupplementFavoriteInteractor: removeSupplementFavoriteInteractor,
  );


  final routinesTabBloc = RoutinesTabBloc(
    getFoodRoutinesInteractor: getFoodRoutinesInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getRoutinesInteractor: getRoutinesInteractor,
    getSupplementRoutinesInteractor: getSupplementRoutinesInteractor,
    removeFoodRoutineInteractor: removeFoodRoutineInteractor,
    deleteFoodRoutineInteractor: deleteFoodRoutineInteractor,
    deleteSportRoutineInteractor: deleteSportRoutineInteractor,
    removeSportRoutineInteractor: removeSportRoutineInteractor,
    deleteSupplementRoutineInteractor: deleteSupplementRoutineInteractor,
    removeSupplementRoutineInteractor: removeSupplementRoutineInteractor,
  );

  routinesTabBloc.add(InitializeRoutinesTabEvent());

  final sportItemsBloc = SportItemsBloc(
    getUserIdInteractor: getUserIdInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    deleteSportEventInteractor: deleteSportEventInteractor,
    removeSportEventInteractor: removeSportEventInteractor,
    updateEventsInteractor: updateEventsInteractor,
    healthSyncRepository: healthSyncRepository,
  );

  final itemUpdateBloc = ItemUpdateBloc(
      getMasterFileInteractor: getMasterFileInteractor,
    uploadFoodEventInteractor: uploadFoodEventInteractor,
    saveFoodEventInteractor: saveFoodEventInteractor,
  );

  final sportUpdateBloc = SportUpdateBloc(
      getMasterFileInteractor: getMasterFileInteractor,
    uploadSportEventsInteractor: uploadSportEventsInteractor,
    saveSportEventInteractor: saveSportEventInteractor,
  );

  final supplementsBloc = SupplementsBloc(
    getProfileInteractor: getProfileInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    uploadSupplementEventInteractor: uploadSupplementEventInteractor,
    saveSupplementEventInteractor: saveSupplementEventInteractor,
    uploadSupplementFavoriteInteractor: uploadSupplementFavoriteInteractor,
    saveSupplementFavoriteInteractor: saveSupplementFavoriteInteractor,
    getSupplementFavoritesInteractor: getSupplementFavoritesInteractor,
    uploadSupplementRoutineInteractor: uploadSupplementRoutineInteractor,
    saveSupplementRoutineInteractor: saveSupplementRoutineInteractor,
    getUserIdInteractor: getUserIdInteractor,
    getRecentSupplementItemsInteractor: getRecentSupplementItemsInteractor,
  );

  final supplementsDetailBloc = SupplementsDetailBloc(
    getDaySupplementEventsInteractor: getDaySupplementEventsInteractor,
    deleteSupplementEventInteractor: deleteSupplementEventInteractor,
    removeSupplementEventInteractor: removeSupplementEventInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
    getProfileInteractor: getProfileInteractor,
    updateEventsInteractor: updateEventsInteractor,
  );

  final updateSupplementBloc = UpdateSupplementBloc(
      getMasterFileInteractor: getMasterFileInteractor,
      uploadSupplementFavoriteInteractor: uploadSupplementFavoriteInteractor,
      saveSupplementFavoriteInteractor: saveSupplementFavoriteInteractor,
      uploadSupplementRoutineInteractor: uploadSupplementRoutineInteractor,
      saveSupplementRoutineInteractor: saveSupplementRoutineInteractor,
      getUserIdInteractor: getUserIdInteractor,
  );

  final updateMealBloc = UpdateMealBloc(
    uploadFoodFavoriteInteractor: uploadFoodFavoriteInteractor,
      saveFoodFavoriteInteractor: saveFoodFavoriteInteractor,
      uploadFoodRoutineInteractor: uploadFoodRoutineInteractor,
      saveFoodRoutineInteractor: saveFoodRoutineInteractor,
      getMasterFileInteractor: getMasterFileInteractor,
  );

  final updateSportBloc = UpdateSportBloc(
    getMasterFileInteractor: getMasterFileInteractor,
    uploadSportFavoriteInteractor: uploadSportFavoriteInteractor,
    saveSportFavoriteInteractor: saveSportFavoriteInteractor,
    uploadRoutineInteractor: uploadRoutineInteractor,
    saveRoutineInteractor: saveRoutineInteractor,
  );

  final settingsBloc = SettingsBloc(
      signOutInteractor: signOutInteractor,
      eraseDatabaseInteractor: eraseDatabaseInteractor,
      sharedPreferences: sharedPreferences,
      fcmApi: fcmApi,
  );

  // Health Sync
  final checkHealthSyncStatusInteractor = CheckHealthSyncStatusInteractorImpl(
    healthSyncRepository: healthSyncRepository,
  );

  final requestHealthPermissionsInteractor = RequestHealthPermissionsInteractorImpl(
    healthSyncRepository: healthSyncRepository,
  );

  final toggleHealthSyncInteractor = ToggleHealthSyncInteractorImpl(
    healthSyncRepository: healthSyncRepository,
  );

  final syncHealthActivitiesInteractor = SyncHealthActivitiesInteractorImpl(
    healthSyncRepository: healthSyncRepository,
    localStorageRepository: localStorageRepository,
    preferencesRepository: prefsRepository,
    saveSportEventInteractor: saveSportEventInteractor,
    sportEventsRepository: sportEventsRepository,
  );

  final healthSyncBloc = HealthSyncBloc(
    healthSyncRepository: healthSyncRepository,
    checkHealthSyncStatusInteractor: checkHealthSyncStatusInteractor,
    requestHealthPermissionsInteractor: requestHealthPermissionsInteractor,
    toggleHealthSyncInteractor: toggleHealthSyncInteractor,
    syncHealthActivitiesInteractor: syncHealthActivitiesInteractor,
    getTodaySportsInteractor: getTodaySportsInteractor,
    getMasterFileInteractor: getMasterFileInteractor,
  );

  // Initialize WorkManager for background health sync (non-blocking)
  HealthSyncBackgroundService.initialize().catchError((e) {
    // Silently ignore WorkManager initialization errors -
    // background sync is optional and app should still work without it
    debugPrint('WorkManager initialization failed: $e');
  });

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
        BlocProvider<MicroNutrientsWeeklyBloc>(create: (context) => microNutrientsWeeklyBloc,),
        BlocProvider<MealTimeDetailsBloc>(create: (context) => mealTimeDetailsBloc,),
        BlocProvider<FavoritesTabsBloc>(create: (context) => favoritesTabsBloc,),
        BlocProvider<RoutinesTabBloc>(create: (context) => routinesTabBloc,),
        BlocProvider<SportItemsBloc>(create: (context) => sportItemsBloc,),
        BlocProvider<ItemUpdateBloc>(create: (context) => itemUpdateBloc,),
        BlocProvider<SportUpdateBloc>(create: (context) => sportUpdateBloc,),
        BlocProvider<SupplementsBloc>(create: (context) => supplementsBloc,),
        BlocProvider<SupplementsDetailBloc>(create: (context) => supplementsDetailBloc,),
        BlocProvider<UpdateSupplementBloc>(create: (context) => updateSupplementBloc,),
        BlocProvider<UpdateMealBloc>(create: (context) => updateMealBloc,),
        BlocProvider<UpdateSportBloc>(create: (context) => updateSportBloc,),
        BlocProvider<SettingsBloc>(create: (context) => settingsBloc,),
        BlocProvider<HealthSyncBloc>(create: (context) => healthSyncBloc,),
        BlocProvider<FoodScannerBloc>(create: (context) {
          // FuzzyMatcher is initialized lazily when the scanner screen
          // is opened — call bloc.initializeMatcher(masterFoods) there.
          //
          // Claude Vision API key: pass via --dart-define=CLAUDE_API_KEY=sk-...
          // or set it directly here for development.
          const claudeApiKey = String.fromEnvironment('CLAUDE_API_KEY');
          return FoodScannerBloc(
            barcodeProvider: OpenFoodFactsBarcodeProvider(),
            scannedFoodRepository: scannedFoodRepository,
            claudeVisionProvider: claudeApiKey.isNotEmpty
                ? ClaudeVisionProvider(apiKey: claudeApiKey)
                : null,
          );
        }),
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
          MicroNutrientsWeeklyScreen.routeName:(_) => const MicroNutrientsWeeklyScreen(),
          MealTimeDetailScreen.routeName:(_) => const MealTimeDetailScreen(),
          BarCodeScanningScreen.routeName:(_) => const BarCodeScanningScreen(),
          BarcodeDetailScreen.routeName:(_) => const BarcodeDetailScreen(),
          MealTimeItemScreen.routeName:(_) => const MealTimeItemScreen(),
          FavoritesTabHolder.routeName:(_) => const FavoritesTabHolder(),
          RoutinesTabHolder.routeName:(_) => const RoutinesTabHolder(),
          SportItemsScreen.routeName:(_) => const SportItemsScreen(),
          FecesUrineTabs.routeName:(_) => const FecesUrineTabs(),
          ItemUpdateScreen.routeName:(_) => const ItemUpdateScreen(),
          SportUpdateScreen.routeName:(_) => const SportUpdateScreen(),
          SupplementsScreen.routeName:(_) => const SupplementsScreen(),
          SupplementsDetailScreen.routeName:(_) => const SupplementsDetailScreen(),
          UpdateSupplementScreen.routeName:(_) => const UpdateSupplementScreen(),
          UpdateMealScreen.routeName:(_) => const UpdateMealScreen(),
          UpdateSportScreen.routeName:(_) => const UpdateSportScreen(),
          SettingsScreen.routeName:(_) => const SettingsScreen(),
          PolicyScreen.routeName:(_) => const PolicyScreen(),
          ObjectivesProfileScreen.routeName: (_) => const ObjectivesProfileScreen(),
          HealthSyncOnboardingScreen.routeName:(_) => const HealthSyncOnboardingScreen(),
          HealthSyncSettingsScreen.routeName:(_) => const HealthSyncSettingsScreen(),
        },
      ),
    ),
  );

  // Ensure Chuck is initialized in the app lifecycle
  chuck.showInspector();
}

/// Initializes Amplify/Cognito with retry logic.
/// AWSMobileClient can timeout on first launch (clean install) if network is slow.
Future<CognitoAuthenticationService> _initAmplifyWithRetry() async {
  const maxAttempts = 3;
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await CognitoAuthenticationService.init();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      // Wait before retrying: 2s, 4s
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  // Unreachable, but satisfies the compiler
  return await CognitoAuthenticationService.init();
}

/// Fetches reference data (nutrients, nutrient loss, sport METs) in the
/// background at app startup. Populates Drift tables for client-side
/// calculations. Non-blocking — failures are silently ignored.
void _fetchReferenceData(ReferenceDataApi api, ReferenceDataService service) {
  service.refreshIfNeeded(
    fetchNutrients: () async {
      try {
        final raw = await api.fetchNutrients();
        final parsed = jsonDecode(raw);
        // S3 format: { "v": <int>, "data": { "nutrientList": [...] } }
        final data = parsed['data'];
        final list = data is Map ? data['nutrientList'] : data;
        return ReferencePayload(
          version: parsed['v'] as int? ?? 0,
          json: jsonEncode(list),
        );
      } catch (_) {
        return null;
      }
    },
    fetchNutrientLoss: () async {
      try {
        final raw = await api.fetchNutrientLossTable();
        final parsed = jsonDecode(raw);
        // S3 format: { "v": <int>, "data": { "cookingMethods": [...] } }
        final data = parsed['data'];
        final list = data is Map ? data['cookingMethods'] : data;
        return ReferencePayload(
          version: parsed['v'] as int? ?? 0,
          json: jsonEncode(list),
        );
      } catch (_) {
        return null;
      }
    },
    fetchSportMets: () async {
      try {
        final raw = await api.fetchSportMets();
        final parsed = jsonDecode(raw);
        // S3 format: { "v": <int>, "data": { "sports": [...] } }
        final data = parsed['data'];
        final list = data is Map ? data['sports'] : data;
        return ReferencePayload(
          version: parsed['v'] as int? ?? 0,
          json: jsonEncode(list),
        );
      } catch (_) {
        return null;
      }
    },
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
  Hive.registerAdapter(ModelsAppearanceEntityAdapter());
  Hive.registerAdapter(OilTypesEntityAdapter());
  Hive.registerAdapter(OilTypeEntityAdapter());
  Hive.registerAdapter(ConversionFactorsEntityAdapter());
  Hive.registerAdapter(ConversionFactorEntityAdapter());
  Hive.registerAdapter(ConversionFactorsInfoEntityAdapter());
  Hive.registerAdapter(ConversionFactorInfoEntityAdapter());
  Hive.registerAdapter(ConversionInfoEntityAdapter());
  Hive.registerAdapter(FoodRoutineEntityAdapter());
  Hive.registerAdapter(FoodRoutineInEntityAdapter());
  Hive.registerAdapter(SupplementsInfoEntityAdapter());
  Hive.registerAdapter(SupplementInfoEntityAdapter());
  Hive.registerAdapter(SupplementEventsEntityAdapter());
  Hive.registerAdapter(SupplementEventsInfoEntityAdapter());
  Hive.registerAdapter(CookingMethodsOilsInfoEntityAdapter());
  Hive.registerAdapter(CookingMethodOilInfoEntityAdapter());
  Hive.registerAdapter(SyncQueueEntryAdapter());
  Hive.registerAdapter(HealthSyncMetadataEntityAdapter());
  Hive.registerAdapter(SleepEventEntityAdapter());
  Hive.registerAdapter(ScannedFoodEntityAdapter());
}