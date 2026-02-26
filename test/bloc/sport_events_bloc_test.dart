import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
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
  });
}
