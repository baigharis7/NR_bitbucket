import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockUploadWaterEventInteractor mockUploadWaterEvent;
  late MockSaveWaterEventInteractor mockSaveWaterEvent;
  late MockGetWaterEventsTodayInteractor mockGetWaterEventsToday;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockUploadWaterEvent = MockUploadWaterEventInteractor();
    mockSaveWaterEvent = MockSaveWaterEventInteractor();
    mockGetWaterEventsToday = MockGetWaterEventsTodayInteractor();
  });

  WaterEventBloc buildBloc() => WaterEventBloc(
        getUserIdInteractor: mockGetUserId,
        uploadWaterEventInteractor: mockUploadWaterEvent,
        saveWaterEventInteractor: mockSaveWaterEvent,
        getWaterEventsTodayInteractor: mockGetWaterEventsToday,
      );

  group('WaterEventBloc', () {
    blocTest<WaterEventBloc, WaterEventState>(
      'initial state has empty WaterEventMaster and no error',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.waterEventMaster, isNotNull);
        expect(bloc.state.waterQuantities, isEmpty);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<WaterEventBloc, WaterEventState>(
      'InitializeStateAction sets userId, eventDate, and generates quantities',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<WaterEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<WaterEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.waterEventMaster!.userId, 'user123');
        expect(bloc.state.waterEventMaster!.eventDate, isNotNull);
        expect(bloc.state.waterQuantities, isNotEmpty);
        verify(mockGetUserId.execute()).called(1);
      },
    );

    blocTest<WaterEventBloc, WaterEventState>(
      'ChooseWaterQuantityAction sets qty on waterEventMaster',
      build: buildBloc,
      act: (bloc) => bloc.add(ChooseWaterQuantityAction(qty: 0.5)),
      verify: (bloc) {
        expect(bloc.state.waterEventMaster!.qty, 0.5);
      },
    );

    blocTest<WaterEventBloc, WaterEventState>(
      'FinishWaterEventAction uploads and saves on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadWaterEvent.execute(any)).thenAnswer((_) async => true);
        when(mockSaveWaterEvent.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () {
        final state = WaterEventState(
          isLoading: false,
          waterEventMaster: WaterEventMaster('user123', 1000, 1000, 0.33),
          waterQuantities: [0.1, 0.2, 0.33, 0.5],
        );
        return state;
      },
      act: (bloc) => bloc.add(FinishWaterEventAction(onFinish: () {})),
      expect: () => [
        isA<WaterEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<WaterEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockUploadWaterEvent.execute(any)).called(1);
        verify(mockSaveWaterEvent.execute(any)).called(1);
      },
    );

    blocTest<WaterEventBloc, WaterEventState>(
      'FinishWaterEventAction emits error when upload throws',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadWaterEvent.execute(any)).thenThrow(Exception('upload failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishWaterEventAction(onFinish: () {})),
      expect: () => [
        isA<WaterEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<WaterEventState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.uploadingWaterEventError),
      ],
    );

    blocTest<WaterEventBloc, WaterEventState>(
      'ResetStateAction resets waterEventMaster to empty',
      build: buildBloc,
      seed: () => WaterEventState(
        isLoading: false,
        waterEventMaster: WaterEventMaster('user123', 1000, 1000, 0.5),
        waterQuantities: [0.1, 0.5],
      ),
      act: (bloc) => bloc.add(ResetStateAction()),
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.waterEventMaster!.userId, '');
        expect(bloc.state.waterEventMaster!.qty, 0);
      },
    );
  });
}
