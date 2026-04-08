import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nutrenaissance_flutter/data/api/referencedata/reference_data_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
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
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/data/local/models/recipes/recipe_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/supplement_events_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sleepevents/sleep_event_entity.dart';
import 'package:nutrenaissance_flutter/app_bootstrap.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'data/local/models/steps/steps_entity.dart';
import 'firebase_options.dart';

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

  // Firebase init is local config (~50ms), safe to await before runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Crashlytics setup (instant, no network)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // All network-dependent and heavy initialization happens in AppBootstrap
  // after the first frame is painted (splash screen visible immediately)
  runApp(const AppBootstrap());
}

/// Fetches reference data (nutrients, nutrient loss, sport METs, objective-nutrients,
/// nutrient-objective) in the background at app startup. Populates Drift tables
/// for client-side calculations. Non-blocking — failures are silently ignored.
void fetchReferenceData(ReferenceDataApi api, ReferenceDataService service, ProfileComputationService profileComputationService) {
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
    fetchObjectiveNutrients: () async {
      try {
        final raw = await api.fetchObjectiveNutrients();
        final parsed = jsonDecode(raw);
        final data = parsed['data'];
        final objectives = data is Map ? data['objectives'] as List? ?? [] : data as List? ?? [];
        final transformed = <String, dynamic>{};
        for (final obj in objectives) {
          if (obj is Map<String, dynamic>) {
            transformed[obj['code'].toString()] = {
              'nutrients': obj['nutrients'],
              if (obj['type'] != null) 'type': obj['type'],
            };
          }
        }
        return ReferencePayload(
          version: parsed['v'] as int? ?? 0,
          json: jsonEncode(transformed),
        );
      } catch (_) {
        return null;
      }
    },
    fetchNutrientObjective: () async {
      try {
        final raw = await api.fetchNutrientObjective();
        final parsed = jsonDecode(raw);
        final data = parsed['data'];
        final nutrients = data is Map ? data['nutrients'] as List? ?? [] : data as List? ?? [];
        const ageBrackets = ['19-30', '30-50', '50-70', '70+'];
        final transformed = <String, dynamic>{};
        for (final n in nutrients) {
          if (n is! Map<String, dynamic>) continue;
          final name = n['name'] as String?;
          if (name == null) continue;
          final maleRda = <String, dynamic>{};
          final femaleRda = <String, dynamic>{};
          for (int i = 0; i < 4; i++) {
            final bracket = ageBrackets[i];
            final suffix = i + 1;
            final rdaM = (n['male$suffix'] as num?)?.toDouble() ?? 0.0;
            final rdaF = (n['female$suffix'] as num?)?.toDouble() ?? 0.0;
            final ulSuffix = suffix <= 3 ? suffix : 3;
            final ulM = (n['ulMale$ulSuffix'] as num?)?.toDouble() ?? 0.0;
            final ulF = (n['ulFemale$ulSuffix'] as num?)?.toDouble() ?? 0.0;
            maleRda[bracket] = {'rda': rdaM, 'ul': ulM};
            femaleRda[bracket] = {'rda': rdaF, 'ul': ulF};
          }
          transformed[name] = {'male': maleRda, 'female': femaleRda};
        }
        return ReferencePayload(
          version: parsed['v'] as int? ?? 0,
          json: jsonEncode(transformed),
        );
      } catch (_) {
        return null;
      }
    },
  ).then((updated) {
    if (updated) profileComputationService.invalidateCache();
  });
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