import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

/// Save / delete / update flow tests for FecesUrineBloc.
/// Date filtering is covered separately in date_filtering_test.dart.
void main() {
  // Feces.listOfAllFeces() / Urines.listOfAllUrines() use the localizations
  // helper singleton — initialize it once with English locale so the bloc can
  // populate state.fecesList / state.urinesList without a NPE.
  setUpAll(() {
    AppLocalizationsHelperDelegate.instance =
        AppLocalizationsHelper(const Locale('en'));
  });
  late MockGetUserIdInteractor mockGetUserId;
  late MockUploadFecesInteractor mockUploadFeces;
  late MockGetFecesEventsInteractor mockGetFecesEvents;
  late MockSaveFecesEventInteractor mockSaveFecesEvent;
  late MockUploadUrineInteractor mockUploadUrine;
  late MockSaveUrineInteractor mockSaveUrine;
  late MockGetUrineEventsInteractor mockGetUrineEvents;
  late MockDeleteFecesEventInteractor mockDeleteFeces;
  late MockRemoveFecesEventInteractor mockRemoveFeces;
  late MockDeleteUrineEventInteractor mockDeleteUrine;
  late MockRemoveUrineEventInteractor mockRemoveUrine;
  late MockGetFaecesByDateInteractor mockGetFaecesByDate;
  late MockGetUrineByDateInteractor mockGetUrineByDate;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockUploadFeces = MockUploadFecesInteractor();
    mockGetFecesEvents = MockGetFecesEventsInteractor();
    mockSaveFecesEvent = MockSaveFecesEventInteractor();
    mockUploadUrine = MockUploadUrineInteractor();
    mockSaveUrine = MockSaveUrineInteractor();
    mockGetUrineEvents = MockGetUrineEventsInteractor();
    mockDeleteFeces = MockDeleteFecesEventInteractor();
    mockRemoveFeces = MockRemoveFecesEventInteractor();
    mockDeleteUrine = MockDeleteUrineEventInteractor();
    mockRemoveUrine = MockRemoveUrineEventInteractor();
    mockGetFaecesByDate = MockGetFaecesByDateInteractor();
    mockGetUrineByDate = MockGetUrineByDateInteractor();
  });

  FecesUrineBloc buildBloc() => FecesUrineBloc(
        getUserIdInteractor: mockGetUserId,
        uploadFecesInteractor: mockUploadFeces,
        getFecesEventsInteractor: mockGetFecesEvents,
        saveFecesEventInteractor: mockSaveFecesEvent,
        uploadUrineInteractor: mockUploadUrine,
        saveUrineInteractor: mockSaveUrine,
        getUrineEventsInteractor: mockGetUrineEvents,
        deleteFecesEventInteractor: mockDeleteFeces,
        removeFecesEventInteractor: mockRemoveFeces,
        deleteUrineEventInteractor: mockDeleteUrine,
        removeUrineEventInteractor: mockRemoveUrine,
        getFaecesByDateInteractor: mockGetFaecesByDate,
        getUrineByDateInteractor: mockGetUrineByDate,
      );

  void stubDefaults() {
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetFaecesByDate.execute(
      dateTime: anyNamed('dateTime'),
      days: anyNamed('days'),
    )).thenAnswer((_) async => <UploadFeces>[]);
    when(mockGetUrineByDate.execute(
      dateTime: anyNamed('dateTime'),
      days: anyNamed('days'),
    )).thenAnswer((_) async => <UploadFeces>[]);
  }

  group('FecesUrineBloc - InitializeFecesUrineEventAction', () {
    blocTest<FecesUrineBloc, FecesUrineState>(
      'loads feces and urine lists with 14-day chart data',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeFecesUrineEventAction()),
      verify: (bloc) {
        expect(bloc.state.fecesList, isNotNull);
        expect(bloc.state.fecesList!.isNotEmpty, true);
        expect(bloc.state.urinesList, isNotNull);
        expect(bloc.state.urinesList!.isNotEmpty, true);
        verify(mockGetFaecesByDate.execute(days: 14)).called(1);
        verify(mockGetUrineByDate.execute(days: 14)).called(1);
      },
    );
  });

  group('FecesUrineBloc - UpdateFecesEventAction', () {
    blocTest<FecesUrineBloc, FecesUrineState>(
      'sets fecesId when none was selected',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateFecesEventAction(feceId: 3)),
      verify: (bloc) => expect(bloc.state.fecesId, 3),
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'clears fecesId when same value tapped twice (toggle)',
      build: buildBloc,
      seed: () => FecesUrineState(isLoading: false, fecesId: 3),
      act: (bloc) => bloc.add(UpdateFecesEventAction(feceId: 3)),
      verify: (bloc) => expect(bloc.state.fecesId, isNull),
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'replaces fecesId when different value tapped',
      build: buildBloc,
      seed: () => FecesUrineState(isLoading: false, fecesId: 3),
      act: (bloc) => bloc.add(UpdateFecesEventAction(feceId: 5)),
      verify: (bloc) => expect(bloc.state.fecesId, 5),
    );
  });

  group('FecesUrineBloc - UpdateUrineEventAction', () {
    blocTest<FecesUrineBloc, FecesUrineState>(
      'sets urineId when none was selected',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateUrineEventAction(urineId: 2)),
      verify: (bloc) => expect(bloc.state.urineId, 2),
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'clears urineId when same value tapped twice (toggle)',
      build: buildBloc,
      seed: () => FecesUrineState(isLoading: false, urineId: 2),
      act: (bloc) => bloc.add(UpdateUrineEventAction(urineId: 2)),
      verify: (bloc) => expect(bloc.state.urineId, isNull),
    );
  });

  group('FecesUrineBloc - UploadFecesEventAction', () {
    test('is a no-op when fecesId is null (validation)', () async {
      stubDefaults();
      final bloc = buildBloc();

      bloc.add(UploadFecesEventAction(onFinish: () {}));
      await pumpEventQueue();

      verifyNever(mockUploadFeces.execute(any));
      verifyNever(mockSaveFecesEvent.execute(any));
      await bloc.close();
    });

    test(
        'uploads, saves, notifies event bus, and clears fecesId on success',
        () async {
      stubDefaults();
      when(mockUploadFeces.execute(any)).thenAnswer((_) async {});
      when(mockSaveFecesEvent.execute(any)).thenAnswer((_) async {});
      final bloc = buildBloc();
      // Seed state with selected fecesId
      bloc.emit(FecesUrineState(isLoading: false, fecesId: 4));

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      var finishCalled = false;
      bloc.add(UploadFecesEventAction(onFinish: () => finishCalled = true));
      await pumpEventQueue();

      verify(mockUploadFeces.execute(any)).called(1);
      verify(mockSaveFecesEvent.execute(any)).called(1);
      expect(notifications, contains(DataChangedCategory.fecesUrine));
      expect(finishCalled, isTrue);
      expect(bloc.state.fecesId, isNull);
      expect(bloc.state.onError, isNull);

      await sub.cancel();
      await bloc.close();
    });

    blocTest<FecesUrineBloc, FecesUrineState>(
      'emits error state when upload fails',
      build: () {
        stubDefaults();
        when(mockUploadFeces.execute(any)).thenThrow(Exception('upload error'));
        return buildBloc();
      },
      seed: () => FecesUrineState(isLoading: false, fecesId: 4),
      act: (bloc) =>
          bloc.add(UploadFecesEventAction(onFinish: () {})),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
        verifyNever(mockSaveFecesEvent.execute(any));
      },
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'emits error state when save fails after successful upload',
      build: () {
        stubDefaults();
        when(mockUploadFeces.execute(any)).thenAnswer((_) async {});
        when(mockSaveFecesEvent.execute(any)).thenThrow(Exception('save error'));
        return buildBloc();
      },
      seed: () => FecesUrineState(isLoading: false, fecesId: 4),
      act: (bloc) =>
          bloc.add(UploadFecesEventAction(onFinish: () {})),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
        verify(mockUploadFeces.execute(any)).called(1);
      },
    );
  });

  group('FecesUrineBloc - UploadUrineEventAction', () {
    test('is a no-op when urineId is null (validation)', () async {
      stubDefaults();
      final bloc = buildBloc();

      bloc.add(UploadUrineEventAction(onFinish: () {}));
      await pumpEventQueue();

      verifyNever(mockUploadUrine.execute(any));
      verifyNever(mockSaveUrine.execute(any));
      await bloc.close();
    });

    test('uploads, saves, and notifies event bus on success', () async {
      stubDefaults();
      when(mockUploadUrine.execute(any)).thenAnswer((_) async {});
      when(mockSaveUrine.execute(any)).thenAnswer((_) async {});
      final bloc = buildBloc();
      bloc.emit(FecesUrineState(isLoading: false, urineId: 2));

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(UploadUrineEventAction(onFinish: () {}));
      await pumpEventQueue();

      verify(mockUploadUrine.execute(any)).called(1);
      verify(mockSaveUrine.execute(any)).called(1);
      expect(notifications, contains(DataChangedCategory.fecesUrine));
      expect(bloc.state.urineId, isNull);

      await sub.cancel();
      await bloc.close();
    });

    blocTest<FecesUrineBloc, FecesUrineState>(
      'emits error when upload fails',
      build: () {
        stubDefaults();
        when(mockUploadUrine.execute(any)).thenThrow(Exception('network'));
        return buildBloc();
      },
      seed: () => FecesUrineState(isLoading: false, urineId: 2),
      act: (bloc) =>
          bloc.add(UploadUrineEventAction(onFinish: () {})),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
      },
    );
  });

  group('FecesUrineBloc - DeleteFecesEventAction', () {
    final feces = UploadFeces(
      userId: 'user123',
      eventId: 1700000000000,
      fecesId: 4,
    );

    test('deletes remotely, removes locally, and notifies event bus',
        () async {
      stubDefaults();
      when(mockDeleteFeces.execute(any, any)).thenAnswer((_) async {});
      when(mockRemoveFeces.execute(any)).thenAnswer((_) async {});
      final bloc = buildBloc();

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(DeleteFecesEventAction(
        uploadFeces: feces,
        onFinish: () {},
      ));
      await pumpEventQueue();

      verify(mockDeleteFeces.execute('user123', 1700000000000)).called(1);
      verify(mockRemoveFeces.execute(feces)).called(1);
      expect(notifications, contains(DataChangedCategory.fecesUrine));

      await sub.cancel();
      await bloc.close();
    });

    blocTest<FecesUrineBloc, FecesUrineState>(
      'emits error when remote delete fails',
      build: () {
        stubDefaults();
        when(mockDeleteFeces.execute(any, any))
            .thenThrow(Exception('network'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFecesEventAction(
        uploadFeces: feces,
        onFinish: () {},
      )),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
        verifyNever(mockRemoveFeces.execute(any));
      },
    );
  });

  group('FecesUrineBloc - DeleteUrineEventAction', () {
    final urine = UploadFeces(
      userId: 'user123',
      eventId: 1700000000000,
      fecesId: 2,
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'deletes remotely and removes locally',
      build: () {
        stubDefaults();
        when(mockDeleteUrine.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveUrine.execute(any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteUrineEventAction(
        uploadFeces: urine,
        onFinish: () {},
      )),
      verify: (bloc) {
        verify(mockDeleteUrine.execute('user123', 1700000000000)).called(1);
        verify(mockRemoveUrine.execute(urine)).called(1);
      },
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'emits error when remote delete fails',
      build: () {
        stubDefaults();
        when(mockDeleteUrine.execute(any, any))
            .thenThrow(Exception('network'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteUrineEventAction(
        uploadFeces: urine,
        onFinish: () {},
      )),
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadingSportEventError);
        verifyNever(mockRemoveUrine.execute(any));
      },
    );
  });

  group('FecesUrineBloc - 14-day chart data', () {
    final today = DateTime(2026, 4, 27);

    blocTest<FecesUrineBloc, FecesUrineState>(
      'feces chart removes the 0 bucket and keeps 7 entries',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializationFecesEventAction()),
      verify: (bloc) {
        expect(bloc.state.chart14DaysData, isNotNull);
        // Bristol scale 1..7 only (bucket 0 removed)
        expect(bloc.state.chart14DaysData!.length, 7);
        for (final entry in bloc.state.chart14DaysData!) {
          expect(entry['fecesId'], isNot(0));
          expect(entry['count'], 0.0);
        }
      },
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'computes feces chart count percentages out of 14 days',
      build: () {
        stubDefaults();
        when(mockGetFaecesByDate.execute(
          dateTime: today,
          days: 14,
        )).thenAnswer((_) async => [
              UploadFeces(userId: 'u', eventId: 1, fecesId: 3),
              UploadFeces(userId: 'u', eventId: 2, fecesId: 3),
              UploadFeces(userId: 'u', eventId: 3, fecesId: 5),
            ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        UpdateCalendarDateFecesUrineEventAction(dateTime: today),
      ),
      verify: (bloc) {
        final chart = bloc.state.chart14DaysData!;
        final bucket3 = chart.firstWhere((e) => e['fecesId'] == 3);
        final bucket5 = chart.firstWhere((e) => e['fecesId'] == 5);
        // 2 / 14 * 100 ≈ 14.28%
        expect(bucket3['count'], closeTo(14.28, 0.1));
        // 1 / 14 * 100 ≈ 7.14%
        expect(bucket5['count'], closeTo(7.14, 0.1));
      },
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'urine chart keeps all 8 buckets (0..7) including 0',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializationUrineEventAction()),
      verify: (bloc) {
        expect(bloc.state.urineChart14DaysData, isNotNull);
        // Urine chart keeps bucket 0 unlike feces
        expect(bloc.state.urineChart14DaysData!.length, 8);
      },
    );
  });
}
