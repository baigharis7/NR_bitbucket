import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';

// Repository Mocks
class MockHealthSyncRepository extends Mock implements HealthSyncRepository {}

class MockLocalStorageRepository extends Mock implements LocalStorageRepository {}

class MockPreferencesRepository extends Mock implements PreferencesRepository {}

class MockSportEventsRepository extends Mock implements SportEventsRepository {}

// Interactor Mocks
class MockCheckHealthSyncStatusInteractor extends Mock
    implements CheckHealthSyncStatusInteractor {}

class MockRequestHealthPermissionsInteractor extends Mock
    implements RequestHealthPermissionsInteractor {}

class MockToggleHealthSyncInteractor extends Mock
    implements ToggleHealthSyncInteractor {}

class MockSyncHealthActivitiesInteractor extends Mock
    implements SyncHealthActivitiesInteractor {}

class MockUploadSportEventsInteractor extends Mock
    implements UploadSportEventsInteractor {}

class MockSaveSportEventInteractor extends Mock
    implements SaveSportEventInteractor {}
