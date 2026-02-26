import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetDaySupplementEventsInteractor mockGetDaySupplementEvents;
  late MockDeleteSupplementEventInteractor mockDeleteSupplementEvent;
  late MockRemoveSupplementEventInteractor mockRemoveSupplementEvent;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetProfileInteractor mockGetProfile;
  late MockUpdateEventsInteractor mockUpdateEvents;

  setUp(() {
    mockGetDaySupplementEvents = MockGetDaySupplementEventsInteractor();
    mockDeleteSupplementEvent = MockDeleteSupplementEventInteractor();
    mockRemoveSupplementEvent = MockRemoveSupplementEventInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetProfile = MockGetProfileInteractor();
    mockUpdateEvents = MockUpdateEventsInteractor();
  });

  SupplementsDetailBloc buildBloc() => SupplementsDetailBloc(
        getDaySupplementEventsInteractor: mockGetDaySupplementEvents,
        deleteSupplementEventInteractor: mockDeleteSupplementEvent,
        removeSupplementEventInteractor: mockRemoveSupplementEvent,
        getMasterFileInteractor: mockGetMasterFile,
        getProfileInteractor: mockGetProfile,
        updateEventsInteractor: mockUpdateEvents,
      );

  group('SupplementsDetailBloc', () {
    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'initial state is not loading with empty supplement events',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.supplementEvents, isEmpty);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'InitializeSupplementsDetailEvent loads profile, supplements info, and events',
      build: () {
        when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
        when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
            .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
        when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeSupplementsDetailEvent(eventDate: DateTime(2026, 2, 15))),
      expect: () => [
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
        // SummaryInitializeSupplementsDetailEvent queued by init handler
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetProfile.execute()).called(1);
        verify(mockGetMasterFile.execute(MasterFilesType.supplementsInfo)).called(1);
        verify(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime'))).called(1);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'InitializeSupplementsDetailEvent triggers summary refresh when updateEvents returns true',
      build: () {
        when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
        when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
            .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
        when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeSupplementsDetailEvent(eventDate: DateTime(2026, 2, 15))),
      expect: () => [
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
        // SummaryInitializeSupplementsDetailEvent queued by init handler
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
        // updateEvents returns true → second summary + emit
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'DeleteSupplementEventAction deletes and removes on success',
      build: () {
        when(mockDeleteSupplementEvent.execute(any)).thenAnswer((_) async {});
        when(mockRemoveSupplementEvent.execute(any)).thenAnswer((_) async {});
        // These are called by the re-init triggered after delete
        when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
        when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
            .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
        when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSupplementEventAction(
        supplement: SupplementSimple(userId: 'user123', eventId: 1, eventDate: 1000),
      )),
      verify: (bloc) {
        verify(mockDeleteSupplementEvent.execute(any)).called(1);
        verify(mockRemoveSupplementEvent.execute(any)).called(1);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'DeleteSupplementEventAction emits error when remote delete fails',
      build: () {
        when(mockDeleteSupplementEvent.execute(any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSupplementEventAction(
        supplement: SupplementSimple(userId: 'user123', eventId: 1, eventDate: 1000),
      )),
      expect: () => [
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SupplementsDetailState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSupplementEventError),
      ],
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'DeleteSupplementEventAction emits error when local remove fails',
      build: () {
        when(mockDeleteSupplementEvent.execute(any)).thenAnswer((_) async {});
        when(mockRemoveSupplementEvent.execute(any)).thenThrow(Exception('local fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteSupplementEventAction(
        supplement: SupplementSimple(userId: 'user123', eventId: 1, eventDate: 1000),
      )),
      expect: () => [
        isA<SupplementsDetailState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SupplementsDetailState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.removeSupplementEventError),
      ],
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'UpdateEventsDateSupplementsDetailEvent sets date and re-initializes',
      build: () {
        when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
        when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
            .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
        when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateEventsDateSupplementsDetailEvent(dateTime: DateTime(2026, 3, 1))),
      verify: (bloc) {
        expect(bloc.state.eventDate, DateTime(2026, 3, 1));
      },
    );
  });
}
