import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockUploadLiquidEventInteractor mockUploadLiquidEvent;
  late MockSaveLiquidEventInteractor mockSaveLiquidEvent;
  late MockGetWeekLiquidEventsInteractor mockGetWeekLiquidEvents;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockUploadLiquidEvent = MockUploadLiquidEventInteractor();
    mockSaveLiquidEvent = MockSaveLiquidEventInteractor();
    mockGetWeekLiquidEvents = MockGetWeekLiquidEventsInteractor();
  });

  LiquidEventBloc buildBloc() => LiquidEventBloc(
        getUserIdInteractor: mockGetUserId,
        getMasterFileInteractor: mockGetMasterFile,
        uploadLiquidEventInteractor: mockUploadLiquidEvent,
        saveLiquidEventInteractor: mockSaveLiquidEvent,
        getWeekLiquidEventsInteractor: mockGetWeekLiquidEvents,
      );

  group('LiquidEventBloc', () {
    blocTest<LiquidEventBloc, LiquidEventState>(
      'initial state is not loading with empty liquids',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.liquidsInEvent, isEmpty);
        expect(bloc.state.weeklyFrequentLiquids, isEmpty);
        expect(bloc.state.isEdit, false);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'InitializeStateAction loads drink names and weekly liquids',
      build: () {
        when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
            .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
                  FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
                ));
        when(mockGetWeekLiquidEvents.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames)).called(1);
        verify(mockGetWeekLiquidEvents.execute()).called(1);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'ReceiveEventDateAction sets event date',
      build: buildBloc,
      act: (bloc) => bloc.add(ReceiveEventDateAction(dateTime: DateTime(2026, 2, 17))),
      verify: (bloc) {
        expect(bloc.state.eventDate, DateTime(2026, 2, 17).millisecondsSinceEpoch);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'AddLiquidFromEventAction adds liquid to event list',
      build: buildBloc,
      act: (bloc) => bloc.add(AddLiquidFromEventAction(
        liquid: LiquidInEvent(id: 42, qty: 200),
      )),
      verify: (bloc) {
        expect(bloc.state.liquidsInEvent!.length, 1);
        expect(bloc.state.liquidsInEvent!.first.id, 42);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'AddLiquidFromEventAction replaces existing liquid with same id',
      build: buildBloc,
      act: (bloc) {
        bloc.add(AddLiquidFromEventAction(liquid: LiquidInEvent(id: 42, qty: 100)));
        bloc.add(AddLiquidFromEventAction(liquid: LiquidInEvent(id: 42, qty: 300)));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.liquidsInEvent!.length, 1);
        expect(bloc.state.liquidsInEvent!.first.qty, 300);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'RemoveLiquidFromEventAction removes liquid from list',
      build: buildBloc,
      act: (bloc) {
        final liquid = LiquidInEvent(id: 42, qty: 200);
        bloc.add(AddLiquidFromEventAction(liquid: liquid));
        bloc.add(RemoveLiquidFromEventAction(liquid: liquid));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.liquidsInEvent, isEmpty);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'FinishLiquidEventAction uploads and saves on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadLiquidEvent.execute(any))
            .thenAnswer((_) async => UploadLiquidEvent('user123', 1000, [], 0, uploadSuccess: true));
        when(mockSaveLiquidEvent.execute(any, any)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishLiquidEventAction(onFinish: () {})),
      expect: () => [
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockUploadLiquidEvent.execute(any)).called(1);
        verify(mockSaveLiquidEvent.execute(any, any)).called(1);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'FinishLiquidEventAction emits error when upload fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadLiquidEvent.execute(any)).thenThrow(Exception('upload failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishLiquidEventAction(onFinish: () {})),
      expect: () => [
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadLiquidEventError);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'FinishLiquidEventAction emits error when upload returns success=false',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockUploadLiquidEvent.execute(any))
            .thenAnswer((_) async => UploadLiquidEvent('user123', 1000, [], 0, uploadSuccess: false));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishLiquidEventAction(onFinish: () {})),
      expect: () => [
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LiquidEventState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.onError, ErrorTypes.uploadLiquidEventError);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'ResetLiquidEventInfoAction clears state',
      build: buildBloc,
      act: (bloc) => bloc.add(ResetLiquidEventInfoAction()),
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.isEdit, false);
      },
    );

    blocTest<LiquidEventBloc, LiquidEventState>(
      'AddLiquidFrequentEventAction sets frequentLiquidAdded',
      build: buildBloc,
      act: (bloc) => bloc.add(AddLiquidFrequentEventAction(
        liquidFrequent: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
      )),
      verify: (bloc) {
        expect(bloc.state.frequentLiquidAdded, isNotNull);
        expect(bloc.state.frequentLiquidAdded!.userId, 'user123');
      },
    );
  });
}
