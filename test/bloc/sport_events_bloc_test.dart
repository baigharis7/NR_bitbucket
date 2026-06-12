import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub flutter_timezone for DateTimeHelper.getDeviceIANATimeZone()
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter_timezone'),
    (MethodCall methodCall) async =>
        methodCall.method == 'getLocalTimezone' ? 'UTC' : null,
  );

  late MockGetUserIdInteractor mockGetUserId;
  late MockSaveSportEventInteractor mockSaveSportEvent;
  late MockUploadSportEventsInteractor mockUploadSportEvent;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetSportFavoritesInteractor mockGetSportFavorites;
  late MockGetWeekSportsInteractor mockGetWeekSports;
  late MockUploadRoutineInteractor mockUploadRoutine;
  late MockSaveRoutineInteractor mockSaveRoutine;
  late MockUploadSportFavoriteInteractor mockUploadSportFavorite;
  late MockSaveSportFavoriteInteractor mockSaveSportFavorite;
  late MockDeleteSportFavoriteInteractor mockDeleteSportFavorite;
  late MockRemoveSportFavoriteInteractor mockRemoveSportFavorite;
  late MockGetRecentSportItemsInteractor mockGetRecentSportItems;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockSaveSportEvent = MockSaveSportEventInteractor();
    mockUploadSportEvent = MockUploadSportEventsInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetSportFavorites = MockGetSportFavoritesInteractor();
    mockGetWeekSports = MockGetWeekSportsInteractor();
    mockUploadRoutine = MockUploadRoutineInteractor();
    mockSaveRoutine = MockSaveRoutineInteractor();
    mockUploadSportFavorite = MockUploadSportFavoriteInteractor();
    mockSaveSportFavorite = MockSaveSportFavoriteInteractor();
    mockDeleteSportFavorite = MockDeleteSportFavoriteInteractor();
    mockRemoveSportFavorite = MockRemoveSportFavoriteInteractor();
    mockGetRecentSportItems = MockGetRecentSportItemsInteractor();
  });

  SportEventsBloc buildBloc() => SportEventsBloc(
        getUserIdInteractor: mockGetUserId,
        saveSportEventInteractor: mockSaveSportEvent,
        uploadSportsEventInteractor: mockUploadSportEvent,
        getMasterFileInteractor: mockGetMasterFile,
        getSportFavoritesInteractor: mockGetSportFavorites,
        getWeekSportsInteractor: mockGetWeekSports,
        uploadRoutineInteractor: mockUploadRoutine,
        saveRoutineInteractor: mockSaveRoutine,
        uploadSportFavoriteInteractor: mockUploadSportFavorite,
        saveSportFavoriteInteractor: mockSaveSportFavorite,
        deleteSportFavoriteInteractor: mockDeleteSportFavorite,
        removeSportFavoriteInteractor: mockRemoveSportFavorite,
        getRecentSportItemsInteractor: mockGetRecentSportItems,
      );

  group('SportEventsBloc', () {
    blocTest<SportEventsBloc, SportEventsState>(
      'initial state is not loading with empty sport info',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.sportsInfo!.sportsInfoMaster, isEmpty);
        expect(bloc.state.isEdit, false);
        expect(bloc.state.favSports, isEmpty);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'InitializeStateAction loads sportsInfo, favorites, and recent items',
      build: () {
        when(mockGetMasterFile.execute(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => SportsInfoMaster(sportsInfoMaster: [
                  SportInfoMaster(id: 1, en: 'Running', es: 'Correr', mets: 8),
                ]));
        when(mockGetSportFavorites.execute())
            .thenAnswer((_) async => <AddSportFavorite>[]);
        when(mockGetRecentSportItems.execute())
            .thenAnswer((_) async => <AddSportFavorite>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<SportEventsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SportEventsState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetMasterFile.execute(MasterFilesType.sportsInfo)).called(1);
        verify(mockGetSportFavorites.execute()).called(1);
        verify(mockGetRecentSportItems.execute()).called(1);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateCalendarDateSportEventAction sets calendarDate',
      build: buildBloc,
      act: (bloc) {
        final date = DateTime(2026, 2, 20);
        bloc.add(UpdateCalendarDateSportEventAction(calendarDate: date));
      },
      verify: (bloc) {
        expect(bloc.state.calendarDate, DateTime(2026, 2, 20));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'SetEventSportNameAction sets title on sportSimpleEvent',
      build: buildBloc,
      act: (bloc) => bloc.add(SetEventSportNameAction(sportEventName: 'Morning Run')),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.title, 'Morning Run');
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateIsFavoriteSportEventsActions sets isFavorite',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: true)),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, true);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateIsCreateRoutineSportEventsActions sets isCreateRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, true);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateIsCreateRoutineSportEventsActions auto-initializes scheduleTime when enabling routine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.scheduleTime, isNotNull);
        expect(bloc.state.sportSimpleEvent!.scheduleTime!.isNotEmpty, true);
        // Should be in HH:MM format
        expect(bloc.state.sportSimpleEvent!.scheduleTime!.contains(':'), true);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateIsCreateRoutineSportEventsActions does not overwrite existing scheduleTime',
      build: () {
        final bloc = buildBloc();
        bloc.state.sportSimpleEvent!.scheduleTime = '17:30';
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.scheduleTime, '17:30');
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateIsCreateRoutineSportEventsActions does not set scheduleTime when disabling routine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: false)),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.scheduleTime, isNull);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateTimeOfDaySportEventAction sets scheduleTime',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateTimeOfDaySportEventAction(scheduleTime: '07:00')),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.scheduleTime, '07:00');
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'AddSportEventAction adds sport info to list',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSportEventAction(
        AddSportFavInfo(id: 1, name_en: 'Running', minutes: 30, intensity: 2),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.info!.length, 1);
        expect(bloc.state.sportSimpleEvent!.info!.first.id, 1);
        expect(bloc.state.sportSimpleEvent!.info!.first.minutes, 30);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'RemoveSportEventAction removes sport info from list',
      build: () {
        final bloc = buildBloc();
        bloc.state.sportSimpleEvent!.info = [
          AddSportFavInfo(id: 1, name_en: 'Running', minutes: 30),
          AddSportFavInfo(id: 2, name_en: 'Swimming', minutes: 45),
        ];
        return bloc;
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportInfo: AddSportFavInfo(id: 1, name_en: 'Running', minutes: 30),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.info!.length, 1);
        expect(bloc.state.sportSimpleEvent!.info!.first.id, 2);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'SetMinutesAction updates minutes for existing sport',
      build: () {
        final bloc = buildBloc();
        bloc.state.sportSimpleEvent!.info = [
          AddSportFavInfo(id: 1, name_en: 'Running', minutes: 30),
        ];
        return bloc;
      },
      act: (bloc) => bloc.add(SetMinutesAction(
        sportInfo: AddSportFavInfo(id: 1, name_en: 'Running', minutes: 60),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.info!.first.minutes, 60);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'UpdateSportFromFavoriteTabSportEventsActions sets event and isEdit',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateSportFromFavoriteTabSportEventsActions(
        addSportFavorite: AddSportFavorite(
          eventDate: DateTime(2026, 2, 20).millisecondsSinceEpoch,
          title: 'Morning Run',
          info: [AddSportFavInfo(id: 1, name_en: 'Running', minutes: 30)],
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.title, 'Morning Run');
        expect(bloc.state.isEdit, true);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'AddSportArgumentModelEventAction with preSelectRoutine sets isCreateRoutine true',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSportArgumentModelEventAction(
        sportArgumentsModel: SportArgumentsModel(
          selectedDateTime: DateTime(2026, 2, 25),
          preSelectRoutine: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, true);
        expect(bloc.state.sportSimpleEvent!.isFavorite, isNot(true));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'AddSportArgumentModelEventAction with preSelectFavorite sets isFavorite true',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSportArgumentModelEventAction(
        sportArgumentsModel: SportArgumentsModel(
          selectedDateTime: DateTime(2026, 2, 25),
          preSelectFavorite: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, true);
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, isNot(true));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'AddSportArgumentModelEventAction without preselect keeps both unset',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSportArgumentModelEventAction(
        sportArgumentsModel: SportArgumentsModel(
          selectedDateTime: DateTime(2026, 2, 25),
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, isNot(true));
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, isNot(true));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'initial state has favRecentTab = 0 (Recent)',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 0);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'SwitchFavRecentTabSportAction updates favRecentTab in state',
      build: buildBloc,
      act: (bloc) => bloc.add(SwitchFavRecentTabSportAction(tabIndex: 1)),
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 1);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'PrefillSportForRoutineAction sets isCreateRoutine true and isFavorite false',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSportForRoutineAction(
        addSportFavorite: AddSportFavorite(
          info: [AddSportFavInfo(id: 1, minutes: 30, intensity: 1)],
          title: 'Running',
          isFavorite: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, true);
        expect(bloc.state.sportSimpleEvent!.isFavorite, false);
        expect(bloc.state.sportSimpleEvent!.title, 'Running');
        expect(bloc.state.sportSimpleEvent!.info!.length, 1);
        expect(bloc.state.sportSimpleEvent!.daysOfWeek, isEmpty);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'PrefillSportForRoutineAction preserves calendarDate as eventDate',
      build: () {
        final bloc = buildBloc();
        bloc.state.calendarDate = DateTime(2026, 3, 15);
        return bloc;
      },
      act: (bloc) => bloc.add(PrefillSportForRoutineAction(
        addSportFavorite: AddSportFavorite(
          info: [],
          title: 'Yoga',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, true);
        expect(bloc.state.sportSimpleEvent!.eventDate, DateTime(2026, 3, 15).millisecondsSinceEpoch);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'PrefillSportForFavoriteAction sets isFavorite true and isCreateRoutine false',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSportForFavoriteAction(
        addSportFavorite: AddSportFavorite(
          info: [AddSportFavInfo(id: 1, minutes: 30, intensity: 1)],
          title: 'Running',
          isCreateRoutine: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, true);
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, false);
        expect(bloc.state.sportSimpleEvent!.title, 'Running');
        expect(bloc.state.sportSimpleEvent!.info!.length, 1);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'PrefillSportForFavoriteAction preserves calendarDate as eventDate',
      build: () {
        final bloc = buildBloc();
        bloc.state.calendarDate = DateTime(2026, 3, 15);
        return bloc;
      },
      act: (bloc) => bloc.add(PrefillSportForFavoriteAction(
        addSportFavorite: AddSportFavorite(
          info: [],
          title: 'Yoga',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, true);
        expect(bloc.state.sportSimpleEvent!.eventDate, DateTime(2026, 3, 15).millisecondsSinceEpoch);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'PrefillSportForCustomizeAction sets neither isFavorite nor isCreateRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSportForCustomizeAction(
        addSportFavorite: AddSportFavorite(
          info: [AddSportFavInfo(id: 1, minutes: 30, intensity: 1)],
          title: 'Running',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.sportSimpleEvent!.isFavorite, false);
        expect(bloc.state.sportSimpleEvent!.isCreateRoutine, false);
        expect(bloc.state.sportSimpleEvent!.title, 'Running');
        expect(bloc.state.sportSimpleEvent!.info!.length, 1);
      },
    );
  });

  group('SportEventsBloc - FinishSportEventAction (save flow)', () {
    blocTest<SportEventsBloc, SportEventsState>(
      'uploads, saves locally, and notifies event bus on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadSportEvent.execute(any)).thenAnswer((_) async =>
            SportEventComplete(
              userId: 'user123',
              eventId: 1,
              eventDate: 1700000000000,
              info: [],
              eventKcals: 250,
            ));
        when(mockSaveSportEvent.execute(any, any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) {
        final notifications = <DataChangedCategory>[];
        DashboardEventBus.instance.stream.listen(notifications.add);
        bloc.add(FinishSportEventAction(
          sportEventSimple: SportEventSimple(
            userId: 'user123',
            eventDate: 1700000000000,
            sportName: 'Running',
            info: [],
          ),
          onFinish: () {},
        ));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verify(mockUploadSportEvent.execute(any)).called(1);
        verify(mockSaveSportEvent.execute(any, false)).called(1);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'emits uploadingSportEventError when upload fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadSportEvent.execute(any))
            .thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishSportEventAction(
        sportEventSimple: SportEventSimple(
          userId: 'user123',
          eventDate: 1700000000000,
          sportName: 'Running',
          info: [],
        ),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
        verifyNever(mockSaveSportEvent.execute(any, any));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'emits locallySavingSportEventError when local save fails after upload',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadSportEvent.execute(any)).thenAnswer((_) async =>
            SportEventComplete(
              userId: 'user123',
              eventId: 1,
              eventDate: 1700000000000,
              info: [],
            ));
        when(mockSaveSportEvent.execute(any, any))
            .thenThrow(Exception('hive error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishSportEventAction(
        sportEventSimple: SportEventSimple(
          userId: 'user123',
          eventDate: 1700000000000,
          sportName: 'Running',
          info: [],
        ),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.locallySavingSportEventError);
      },
    );
  });

  group('SportEventsBloc - FinishSportRoutineAddSportAction (routine save)', () {
    blocTest<SportEventsBloc, SportEventsState>(
      'uploads routine, saves locally, and notifies event bus on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadRoutine.execute(any)).thenAnswer((_) async => true);
        when(mockSaveRoutine.execute(any, any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishSportRoutineAddSportAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 1,
          eventDate: 1700000000000,
          info: [],
          isRoutine: true,
          daysOfWeek: [1, 3, 5],
          scheduleTime: '07:00',
        ),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verify(mockUploadRoutine.execute(any)).called(1);
        verify(mockSaveRoutine.execute(any, false)).called(1);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'emits uploadingSportRoutineError on upload failure',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadRoutine.execute(any))
            .thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishSportRoutineAddSportAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 1,
          eventDate: 1700000000000,
          info: [],
          isRoutine: true,
          daysOfWeek: [1],
          scheduleTime: '07:00',
        ),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportRoutineError);
        verifyNever(mockSaveRoutine.execute(any, any));
      },
    );
  });

  group('SportEventsBloc - DeleteFavSportSportEventsAction', () {
    blocTest<SportEventsBloc, SportEventsState>(
      'deletes remotely, removes locally, refreshes favorites',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any))
            .thenAnswer((_) async => true);
        when(mockRemoveSportFavorite.execute(any))
            .thenAnswer((_) async => true);
        when(mockGetSportFavorites.execute())
            .thenAnswer((_) async => <AddSportFavorite>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFavSportSportEventsAction(
        sportFavorite: AddSportFavorite(
          eventId: 42,
          info: [],
        ),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        verify(mockDeleteSportFavorite.execute('user123', 42)).called(1);
        verify(mockRemoveSportFavorite.execute(any)).called(1);
        verify(mockGetSportFavorites.execute()).called(1);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'emits deleteSportFavoriteError when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any))
            .thenThrow(Exception('network'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFavSportSportEventsAction(
        sportFavorite: AddSportFavorite(eventId: 42, info: []),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.deleteSportFavoriteError);
        verifyNever(mockRemoveSportFavorite.execute(any));
      },
    );

    blocTest<SportEventsBloc, SportEventsState>(
      'emits removeSportFavoriteError when local remove returns false',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any))
            .thenAnswer((_) async => true);
        when(mockRemoveSportFavorite.execute(any))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFavSportSportEventsAction(
        sportFavorite: AddSportFavorite(eventId: 42, info: []),
        onFinish: () {},
      )),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.removeSportFavoriteError);
      },
    );
  });

  group('SportEventsBloc - sport lookups (firstWhere crash regression)', () {
    // Regression for crash_analysis.md group 2 (sports): findSportByName /
    // findSportIdByName / findSportById used to throw StateError when a sport
    // name/id from the server catalog had no local match, crashing the screen.
    final running =
        SportInfoMaster(id: 7, en: 'Running', es: 'Correr', mets: 8);

    SportEventsBloc buildWithSports() {
      final bloc = buildBloc();
      bloc.state.sportsInfo = SportsInfoMaster(sportsInfoMaster: [running]);
      return bloc;
    }

    test('findSportByName returns matching sport when it exists', () {
      final bloc = buildWithSports();
      expect(bloc.findSportByName('Running', 'en').id, 7);
      bloc.close();
    });

    test('findSportByName returns empty without throwing on no match', () {
      final bloc = buildWithSports();
      final result = bloc.findSportByName('Swimming', 'en');
      expect(result.id, 0);
      expect(result.en, '');
      bloc.close();
    });

    test('findSportIdByName returns matching id (spanish) when it exists', () {
      final bloc = buildWithSports();
      expect(bloc.findSportIdByName('Correr', 'es'), 7);
      bloc.close();
    });

    test('findSportIdByName returns 0 without throwing on no match', () {
      final bloc = buildWithSports();
      expect(bloc.findSportIdByName('Swimming', 'en'), 0);
      bloc.close();
    });

    test('findSportById returns matching sport when the id exists', () {
      final bloc = buildWithSports();
      expect(bloc.findSportById(7).id, 7);
      bloc.close();
    });

    test('findSportById returns empty without throwing on no match', () {
      final bloc = buildWithSports();
      final result = bloc.findSportById(99);
      expect(result.id, 0);
      expect(result.en, '');
      bloc.close();
    });
  });
}
