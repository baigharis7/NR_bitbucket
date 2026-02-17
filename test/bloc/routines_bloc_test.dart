import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetRoutinesInteractor mockGetRoutines;
  late MockGetUserIdInteractor mockGetUserId;
  late MockDeleteSportRoutineInteractor mockDeleteSportRoutine;
  late MockRemoveSportRoutineInteractor mockRemoveSportRoutine;
  late MockUploadSportFavoriteInteractor mockUploadSportFavorite;
  late MockSaveSportFavoriteInteractor mockSaveSportFavorite;
  late MockDeleteSportFavoriteInteractor mockDeleteSportFavorite;
  late MockRemoveSportFavoriteInteractor mockRemoveSportFavorite;
  late MockGetSportFavoritesInteractor mockGetSportFavorites;

  setUp(() {
    mockGetRoutines = MockGetRoutinesInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockDeleteSportRoutine = MockDeleteSportRoutineInteractor();
    mockRemoveSportRoutine = MockRemoveSportRoutineInteractor();
    mockUploadSportFavorite = MockUploadSportFavoriteInteractor();
    mockSaveSportFavorite = MockSaveSportFavoriteInteractor();
    mockDeleteSportFavorite = MockDeleteSportFavoriteInteractor();
    mockRemoveSportFavorite = MockRemoveSportFavoriteInteractor();
    mockGetSportFavorites = MockGetSportFavoritesInteractor();
  });

  RoutinesBloc buildBloc() => RoutinesBloc(
        getRoutinesInteractor: mockGetRoutines,
        getUserIdInteractor: mockGetUserId,
        deleteSportRoutineInteractor: mockDeleteSportRoutine,
        removeSportRoutineInteractor: mockRemoveSportRoutine,
        uploadSportFavoriteInteractor: mockUploadSportFavorite,
        saveSportFavoriteInteractor: mockSaveSportFavorite,
        deleteSportFavoriteInteractor: mockDeleteSportFavorite,
        removeSportFavoriteInteractor: mockRemoveSportFavorite,
        getSportFavoritesInteractor: mockGetSportFavorites,
      );

  group('RoutinesBloc', () {
    blocTest<RoutinesBloc, RoutinesState>(
      'initial state is not loading',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.routines, isNull);
        expect(bloc.state.sportsFavorite, isNull);
      },
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutinesInitialStateAction loads routines and favorites',
      build: () {
        when(mockGetRoutines.execute()).thenAnswer((_) async => <SportRoutineCompleted>[]);
        when(mockGetSportFavorites.execute()).thenAnswer((_) async => <AddSportFavorite>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutinesInitialStateAction()),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetRoutines.execute()).called(1);
        verify(mockGetSportFavorites.execute()).called(1);
      },
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutineDeleteEventAction deletes and removes routine on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportRoutine.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportRoutine.execute(any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutineDeleteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(userId: 'user123', eventId: 42),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteSportRoutine.execute('user123', 42)).called(1);
        verify(mockRemoveSportRoutine.execute(any)).called(1);
      },
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutineDeleteEventAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportRoutine.execute(any, any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutineDeleteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(userId: 'user123', eventId: 42),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportFavoriteError),
      ],
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutineDeleteEventAction emits error when local remove fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportRoutine.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportRoutine.execute(any)).thenThrow(Exception('local fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutineDeleteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(userId: 'user123', eventId: 42),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportFavoriteError),
      ],
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutineFavoriteEventAction uploads and saves favorite on success',
      build: () {
        when(mockUploadSportFavorite.execute(any)).thenAnswer((_) async => true);
        when(mockSaveSportFavorite.execute(any, any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutineFavoriteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 10,
          eventDate: 1000,
          info: [Info(id: 1, nameEn: 'Running', minutes: 30, intensity: 2)],
          sportName: 'Running',
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockUploadSportFavorite.execute(any)).called(1);
        verify(mockSaveSportFavorite.execute(any, false)).called(1);
      },
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RoutineFavoriteEventAction emits error when upload fails',
      build: () {
        when(mockUploadSportFavorite.execute(any)).thenThrow(Exception('upload fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RoutineFavoriteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 10,
          eventDate: 1000,
          info: [Info(id: 1, nameEn: 'Running', minutes: 30, intensity: 2)],
          sportName: 'Running',
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.uploadingSportEventError),
      ],
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RemoveRoutineFavoriteEventAction deletes and removes on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveSportFavorite.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveRoutineFavoriteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 10,
          eventDate: 1000,
          info: [Info(id: 1, nameEn: 'Running', minutes: 30, intensity: 2)],
          sportName: 'Running',
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteSportFavorite.execute(any, any)).called(1);
        verify(mockRemoveSportFavorite.execute(any)).called(1);
      },
    );

    blocTest<RoutinesBloc, RoutinesState>(
      'RemoveRoutineFavoriteEventAction emits error when delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportFavorite.execute(any, any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveRoutineFavoriteEventAction(
        sportRoutineCompleted: SportRoutineCompleted(
          userId: 'user123',
          eventId: 10,
          eventDate: 1000,
          info: [Info(id: 1, nameEn: 'Running', minutes: 30, intensity: 2)],
          sportName: 'Running',
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<RoutinesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RoutinesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportFavoriteError),
      ],
    );
  });
}
