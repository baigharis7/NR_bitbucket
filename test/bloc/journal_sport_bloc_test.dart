import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetUserKcalInteractor mockGetUserKcal;
  late MockGetTodaySportsInteractor mockGetTodaySports;
  late MockGetWeekSportsInteractor mockGetWeekSports;
  late MockIsNecessaryToShowExplainingCardInteractor mockIsNecessaryToShowCard;
  late MockSaveExplainingCardInteractionInteractor mockSaveCardInteraction;
  late MockGetSportFavoritesInteractor mockGetSportFavorites;
  late MockUploadSportFavoriteInteractor mockUploadSportFavorite;
  late MockSaveSportFavoriteInteractor mockSaveSportFavorite;
  late MockGetUserIdInteractor mockGetUserId;
  late MockDeleteSportFavoriteInteractor mockDeleteSportFavorite;
  late MockRemoveSportFavoriteInteractor mockRemoveSportFavorite;
  late MockDeleteSportEventInteractor mockDeleteSportEvent;
  late MockRemoveSportEventInteractor mockRemoveSportEvent;
  late MockEraseDBLocalEventsInteractor mockEraseDBLocalEvents;
  late MockSynchronizeEventsInteractor mockSynchronizeEvents;

  setUp(() {
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetUserKcal = MockGetUserKcalInteractor();
    mockGetTodaySports = MockGetTodaySportsInteractor();
    mockGetWeekSports = MockGetWeekSportsInteractor();
    mockIsNecessaryToShowCard = MockIsNecessaryToShowExplainingCardInteractor();
    mockSaveCardInteraction = MockSaveExplainingCardInteractionInteractor();
    mockGetSportFavorites = MockGetSportFavoritesInteractor();
    mockUploadSportFavorite = MockUploadSportFavoriteInteractor();
    mockSaveSportFavorite = MockSaveSportFavoriteInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockDeleteSportFavorite = MockDeleteSportFavoriteInteractor();
    mockRemoveSportFavorite = MockRemoveSportFavoriteInteractor();
    mockDeleteSportEvent = MockDeleteSportEventInteractor();
    mockRemoveSportEvent = MockRemoveSportEventInteractor();
    mockEraseDBLocalEvents = MockEraseDBLocalEventsInteractor();
    mockSynchronizeEvents = MockSynchronizeEventsInteractor();
  });

  JournalSportBloc buildBloc() => JournalSportBloc(
        getMasterFileInteractor: mockGetMasterFile,
        getUserKcalInteractor: mockGetUserKcal,
        getTodaySportsInteractor: mockGetTodaySports,
        getWeekSportsInteractor: mockGetWeekSports,
        isNecessaryToShowExplainingCardInteractor: mockIsNecessaryToShowCard,
        saveExplainingCardInteractionInteractor: mockSaveCardInteraction,
        getSportFavoritesInteractor: mockGetSportFavorites,
        uploadSportFavoriteInteractor: mockUploadSportFavorite,
        saveSportFavoriteInteractor: mockSaveSportFavorite,
        getUserIdInteractor: mockGetUserId,
        deleteSportFavoriteInteractor: mockDeleteSportFavorite,
        removeSportFavoriteInteractor: mockRemoveSportFavorite,
        deleteSportEventInteractor: mockDeleteSportEvent,
        removeSportEventInteractor: mockRemoveSportEvent,
        eraseDBLocalEventsInteractor: mockEraseDBLocalEvents,
        synchronizeEventsInteractor: mockSynchronizeEvents,
      );

  group('JournalSportBloc', () {
    blocTest<JournalSportBloc, JournalSportState>(
      'initial state is not loading with empty lists',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.todaySportEvents, isEmpty);
        expect(bloc.state.sportsFavorite, isEmpty);
        expect(bloc.state.showCard, false);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'InitializeStateAction loads all sport data',
      build: () {
        when(mockGetMasterFile.execute(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => SportsInfoMaster(sportsInfoMaster: []));
        when(mockGetUserKcal.execute()).thenAnswer((_) async => 2500);
        when(mockGetTodaySports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
        when(mockGetSportFavorites.execute()).thenAnswer((_) async => <AddSportFavorite>[]);
        when(mockGetWeekSports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
        when(mockIsNecessaryToShowCard.execute(any)).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.userKcal, 2500);
        expect(bloc.state.showCard, false);
        verify(mockGetMasterFile.execute(MasterFilesType.sportsInfo)).called(1);
        verify(mockGetUserKcal.execute()).called(1);
        verify(mockGetTodaySports.execute()).called(1);
        verify(mockGetSportFavorites.execute()).called(1);
        verify(mockGetWeekSports.execute()).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'HideExplainingCardAction sets showCard to false',
      build: () {
        when(mockSaveCardInteraction.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => JournalSportState(isLoading: false, todaySportEvents: [], sportsFavorite: [], showCard: true),
      act: (bloc) => bloc.add(HideExplainingCardAction()),
      verify: (bloc) {
        expect(bloc.state.showCard, false);
        verify(mockSaveCardInteraction.execute(any)).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'AddSportFavNameAction sets sportFavName',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSportFavNameAction(sportFavName: 'Morning Run')),
      verify: (bloc) {
        expect(bloc.state.sportFavName, 'Morning Run');
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'FinishAddSportToFavoriteAction uploads and saves on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadSportFavorite.execute(any)).thenAnswer((_) async => true);
        when(mockSaveSportFavorite.execute(any, any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) {
        bloc.add(FinishAddSportToFavoriteAction(
          sportEvent: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
          onFinish: () {},
        ));
      },
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockUploadSportFavorite.execute(any)).called(1);
        verify(mockSaveSportFavorite.execute(any, false)).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'FinishAddSportToFavoriteAction emits error when upload fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadSportFavorite.execute(any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishAddSportToFavoriteAction(
        sportEvent: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.uploadingSportEventError),
      ],
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'RemoveFavoriteSportAction deletes and removes locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveSportFavorite.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFavoriteSportAction(
        sportFavorite: AddSportFavorite(userId: 'user123', eventDate: 500, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteSportFavorite.execute('user123', 500)).called(1);
        verify(mockRemoveSportFavorite.execute(any)).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'RemoveFavoriteSportAction does nothing when sportFavorite is null',
      build: buildBloc,
      act: (bloc) => bloc.add(RemoveFavoriteSportAction(sportFavorite: null, onFinish: () {})),
      expect: () => [],
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'RemoveFavoriteSportAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any)).thenThrow(Exception('net error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFavoriteSportAction(
        sportFavorite: AddSportFavorite(userId: 'user123', eventDate: 500, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportFavoriteError),
      ],
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'DeleteSportEventAction deletes remotely and locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteSportEvent.execute('user123', 1)).called(1);
        verify(mockRemoveSportEvent.execute(any)).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'DeleteSportEventAction deletes remotely and locally on success for a health-synced event',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 42, eventDate: 86400000, info: [], source: 'health_connect'),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteSportEvent.execute('user123', 42)).called(1);
        verify(mockRemoveSportEvent.execute(any)).called(1);
      },
    );

    blocTest<JournalSportBloc, JournalSportState>(
      'DeleteSportEventAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalSportState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalSportState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportEventError),
      ],
    );
  });
}
