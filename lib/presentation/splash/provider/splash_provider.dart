import 'dart:io';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/master_files_api.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/repository/masterfiles/master_files_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/data/api/fcm/fcm_api.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/eventssync/events_sync_api.dart';
import '../../../data/api/profile/profile_api.dart';
import '../../../data/repository/eventssync/events_synchronization_repository_impl.dart';
import '../../../data/repository/localstorage/local_storage_impl.dart';
import '../../../data/repository/profile/profile_repository_impl.dart';
import '../../../domain/interactor/eventssync/synchronize_events_interactor.dart';
import '../../../domain/interactor/eventssync/synchronize_events_interactor_impl.dart';
import '../../../domain/interactor/localstorage/erase_db_local_events_interactor.dart';
import '../../../domain/interactor/localstorage/erase_db_local_events_interactor_impl.dart';
import '../../../domain/interactor/preferences/get_user_id_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor_impl.dart';
import '../../../domain/repository/eventssync/events_synchronization_repository.dart';
import '../../../domain/repository/localstorage/local_storage.dart';
import '../../../domain/repository/preferences/preferences.dart';
import '../../../domain/repository/preferences/preferences_repository.dart';
import '../../../domain/repository/profile/profile_repository.dart';
import '../../../infrastructure/authentication/cognito_authentication_service.dart';
import '../../../infrastructure/utils/prefs_keys.dart';

class SplashProvider extends ChangeNotifier {
  GetIdTokenInteractor? getIdTokenInteractor;
  late GetProfileInteractor getProfileInteractor;
  late ProfileRepository profileRepository;
  late LocalStorageRepository localStorageRepository;
  late ProfileApi profileApi;
  String? idToken;
  late EraseDBLocalEventsInteractor eraseDBLocalEventsInteractor;
  late EventsSyncApi eventsSyncApi;
  late EventsSynchronizationRequestRepository eventsSynchronizationRequestRepository;
  late SynchronizeEventsInteractor synchronizeEventsInteractor;
  late GetUserIdInteractor getUserIdInteractor;
  late FcmApi fcmApi;

  SplashProvider();

  void init({required Function toLogin, required Function toDashboard}) async {
    try {
      // Singleton — already initialized by AppBootstrap before this screen mounts
      final authenticationService = CognitoAuthenticationService.instance;
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      final Preferences prefs = PreferencesImpl(sharedPreferences);
      final PreferencesRepository prefsRepository = PreferencesRepositoryImpl(prefs: prefs);
      getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);

      // Check auth first — no user means go straight to login
      final userId = getUserIdInteractor.execute();
      if (userId.isEmpty) {
        Future.delayed(
          const Duration(seconds: NumConstants.splashDelay),
          () => toLogin.call(),
        );
        return;
      }

      Chuck chuck = Chuck(
        showNotification: true,
        showInspectorOnShake: true,
        darkTheme: false,
        maxCallsCount: 1000,
      );

      // TODO: These services are already created in main() — pass them in via constructor instead of duplicating
      profileApi = ProfileApi(prefsRepository, authenticationService, chuck);
      localStorageRepository = LocalStorageImpl();
      final syncQueueBox = await Hive.openBox<SyncQueueEntry>('syncQueue');
      final syncQueueService = SyncQueueService(prefsRepository, authenticationService, chuck, syncQueueBox);
      final referenceDatabase = await openReferenceDatabase();
      final profileComputationService = ProfileComputationService(referenceDatabase);
      profileRepository = ProfileRepositoryImpl(profileApi: profileApi, localStorageRepository: localStorageRepository, profileComputationService: profileComputationService, syncQueue: syncQueueService);
      getProfileInteractor = GetProfileInteractorImpl(profileRepository: profileRepository);
      eraseDBLocalEventsInteractor = EraseDBLocalEventsInteractorImpl(localStorageRepository: localStorageRepository);
      eventsSyncApi = EventsSyncApi(prefsRepository, authenticationService, chuck);
      eventsSynchronizationRequestRepository = EventsSynchronizationRequestRepositoryImpl(localStorageRepository: localStorageRepository, eventsSyncApi: eventsSyncApi);
      synchronizeEventsInteractor = SynchronizeEventsInteractorImpl(eventsSynchronizationRequestRepository: eventsSynchronizationRequestRepository);
      fcmApi = FcmApi(prefsRepository, authenticationService, chuck);

      // Sync, FCM registration, and master files update — non-critical, don't block navigation
      try {
        await synchronizeEventsInteractor.execute(userId, fullSync: false);
        final fcmToken = FcmService.instance.token;
        if (fcmToken != null) {
          fcmApi.registerToken(userId, fcmToken, Platform.isIOS ? 'ios' : 'android')
              .catchError((_) {});
        }
      } catch (_) {}

      // Check for master file updates in the background (non-blocking)
      _refreshMasterFiles(prefsRepository, authenticationService, localStorageRepository, referenceDatabase);

      final profile = await getProfileInteractor.execute();
      // Defense-in-depth against incomplete logouts: if the Hive profile
      // belongs to a different user than the current Cognito session, wipe
      // local data and force re-onboarding. Should never fire in practice
      // because logout awaits eraseDatabase, but this catches a kill mid-
      // logout / OS-killed-during-clear / future regressions.
      if (profile != null &&
          profile.userId != null &&
          profile.userId!.isNotEmpty &&
          profile.userId != userId) {
        debugPrint(
            'SplashProvider: userId mismatch (hive=${profile.userId}, cognito=$userId), wiping local data');
        await localStorageRepository.eraseDatabaseInformation();
        toLogin.call();
        return;
      }
      if (profile.isNull() || (profile!.objectives.orEmpty().isEmpty && profile.physicalCharacteristics.isNull())) {
        toLogin.call();
      } else {
        toDashboard.call();
      }
    } catch (e) {
      debugPrint('SplashProvider.init() failed: $e');
      toLogin.call();
    }
  }

  /// Checks for master file updates and saves any new versions locally.
  /// Runs in the background — does not block navigation.
  void _refreshMasterFiles(
    PreferencesRepository prefsRepository,
    CognitoAuthenticationService authenticationService,
    LocalStorageRepository localStorageRepository,
    ReferenceDatabase referenceDatabase,
  ) async {
    try {
      final chuck = Chuck(showNotification: false, showInspectorOnShake: false);
      final masterFilesApi = MasterFilesApi(prefsRepository, authenticationService, chuck);
      final MasterFilesRepository masterFilesRepository = MasterFilesRepositoryImpl(
        localStorageRepository: localStorageRepository,
        masterFilesApi: masterFilesApi,
        referenceDatabase: referenceDatabase,
      );
      final GetMasterFileVersionInteractor getVersion =
          GetMasterFileVersionInteractorImpl(masterFilesRepository: masterFilesRepository);
      final ManageMasterFilesInteractor manage =
          ManageMasterFilesInteractorImpl(masterFilesRepository: masterFilesRepository);
      final SaveMasterFileInteractor save =
          SaveMasterFileInteractorImpl(masterFilesRepository: masterFilesRepository);

      final versions = await Future.wait([
        getVersion.execute(MasterFilesType.cookingMethods),
        getVersion.execute(MasterFilesType.cookingMethodsInfo),
        getVersion.execute(MasterFilesType.oilTypes),
        getVersion.execute(MasterFilesType.conversionFactors),
        getVersion.execute(MasterFilesType.conversionFactorsInfo),
        getVersion.execute(MasterFilesType.foodsAndDrinksNames),
        getVersion.execute(MasterFilesType.nutrientsInfo),
        getVersion.execute(MasterFilesType.objectivesInfo),
        getVersion.execute(MasterFilesType.recommendationGroups),
        getVersion.execute(MasterFilesType.sportsInfo),
        getVersion.execute(MasterFilesType.unitsInfo),
        getVersion.execute(MasterFilesType.unitsFoods),
        getVersion.execute(MasterFilesType.supplementsInfo),
        getVersion.execute(MasterFilesType.subjectiveAnalysis),
        getVersion.execute(MasterFilesType.cookingMethodsOilsInfo),
      ]);

      final MasterFilesResponse response = await manage.execute(
        versions[0], versions[1], versions[2], versions[3], versions[4],
        versions[5], versions[6], versions[7], versions[8], versions[9],
        versions[10], versions[11], versions[12], versions[13], versions[14],
      );

      // Save any updated master files
      response.cookingMethodsResponse.doIfAintNull(() =>
          save.execute(response.cookingMethodsResponse, MasterFilesType.cookingMethods));
      response.cookingMethodsInfoResponse.doIfAintNull(() =>
          save.execute(response.cookingMethodsInfoResponse, MasterFilesType.cookingMethodsInfo));
      response.oilTypesResponse.doIfAintNull(() =>
          save.execute(response.oilTypesResponse, MasterFilesType.oilTypes));
      response.conversionFactorsResponse.doIfAintNull(() =>
          save.execute(response.conversionFactorsResponse, MasterFilesType.conversionFactors));
      response.conversionFactorsInfoResponse.doIfAintNull(() =>
          save.execute(response.conversionFactorsInfoResponse, MasterFilesType.conversionFactorsInfo));
      response.foodsAndDrinksNamesResponse.doIfAintNull(() =>
          save.execute(response.foodsAndDrinksNamesResponse, MasterFilesType.foodsAndDrinksNames));
      response.nutrientsInfoResponse.doIfAintNull(() =>
          save.execute(response.nutrientsInfoResponse, MasterFilesType.nutrientsInfo));
      response.objectivesResponse.doIfAintNull(() =>
          save.execute(response.objectivesResponse, MasterFilesType.objectivesInfo));
      response.recommendationGroupsResponse.doIfAintNull(() =>
          save.execute(response.recommendationGroupsResponse, MasterFilesType.recommendationGroups));
      response.sportsInfoResponse.doIfAintNull(() =>
          save.execute(response.sportsInfoResponse, MasterFilesType.sportsInfo));
      response.unitsInfoResponse.doIfAintNull(() =>
          save.execute(response.unitsInfoResponse, MasterFilesType.unitsInfo));
      response.unitsFoodsResponse.doIfAintNull(() =>
          save.execute(response.unitsFoodsResponse, MasterFilesType.unitsFoods));
      response.supplementsInfoResponse.doIfAintNull(() =>
          save.execute(response.supplementsInfoResponse, MasterFilesType.supplementsInfo));
      response.cookingMethodsOilsInfoResponse.doIfAintNull(() =>
          save.execute(response.cookingMethodsOilsInfoResponse, MasterFilesType.cookingMethodsOilsInfo));

      debugPrint('Master files refresh completed');
    } catch (e) {
      debugPrint('Master files refresh failed (non-critical): $e');
    }
  }
}