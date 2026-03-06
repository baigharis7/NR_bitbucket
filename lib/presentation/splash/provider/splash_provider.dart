import 'dart:io';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
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
    getUserIdInteractor = GetUserIdInteractorImpl(preferencesRepository: prefsRepository);
    fcmApi = FcmApi(prefsRepository, authenticationService, chuck);

    final profile = await getProfileInteractor.execute();
    getIdTokenInteractor = GetIdTokenInteractorImpl(
        preferencesRepository: PreferencesRepositoryImpl(
            prefs: PreferencesImpl(
                await SharedPreferences.getInstance(),
            ),
        ),
    );
    idToken = getIdTokenInteractor!.execute();
    nextScreen(toLogin, toDashboard, profile, prefsRepository);
  }

  void nextScreen(Function toLogin, Function toDashboard, UserProfileModel? profile, PreferencesRepository preferencesRepository) async {
    final userId = getUserIdInteractor.execute();
    if (userId.isNotEmpty) {
      try {
        // final getMasterFileVersionCookingMethods = await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethods);
        // final getMasterFileVersionNutrientsInfo = await getMasterFilesVersionInteractor.execute(MasterFilesType.nutrientsInfo);
        // final getMasterFile = await manageMasterFilesInteractor.execute(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
        // state.isUpdatedDataNeeded = getMasterFileVersionCookingMethods != getMasterFile.cookingMethodsResponse?.v || getMasterFileVersionNutrientsInfo != getMasterFile.nutrientsInfoResponse?.v;
        // await eraseDBLocalEventsInteractor.execute();
        await synchronizeEventsInteractor.execute(getUserIdInteractor.execute(), fullSync: false); // Doing partial sync
        // await preferencesRepository.saveLastFetchTime(PrefsKeys.synchronizeEvents, DateTime.now());
        final fcmToken = FcmService.instance.token;
        if (fcmToken != null) {
          fcmApi.registerToken(userId, fcmToken, Platform.isIOS ? 'ios' : 'android')
              .catchError((_) {});
        }
      } catch(_) {}
      await doAccordingToToken(toLogin, toDashboard, profile);
    } else {
      Future.delayed(
        const Duration(seconds: NumConstants.splashDelay),
            () async => await doAccordingToToken(toLogin, toDashboard, profile),
      );
    }
  }

  Future<void> doAccordingToToken(Function toLogin, Function toDashboard, UserProfileModel? profile) async {
    if (/*idToken == '' || isTokenExpired(idToken.orEmpty())  || */profile.isNull() || (profile!.objectives.orEmpty().isEmpty && profile.physicalCharacteristics.isNull())) {
      toLogin.call();
    } else {
      toDashboard.call();
    }
  }

}