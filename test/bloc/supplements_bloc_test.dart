import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/bloc/supplements_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetProfileInteractor mockGetProfile;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockUploadSupplementEventInteractor mockUploadSupplementEvent;
  late MockSaveSupplementEventInteractor mockSaveSupplementEvent;
  late MockUploadSupplementFavoriteInteractor mockUploadSupplementFavorite;
  late MockSaveSupplementFavoriteInteractor mockSaveSupplementFavorite;
  late MockGetSupplementFavoritesInteractor mockGetSupplementFavorites;
  late MockUploadSupplementRoutineInteractor mockUploadSupplementRoutine;
  late MockSaveSupplementRoutineInteractor mockSaveSupplementRoutine;
  late MockGetUserIdInteractor mockGetUserId;
  late MockGetRecentSupplementItemsInteractor mockGetRecentSupplementItems;

  setUp(() {
    mockGetProfile = MockGetProfileInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockUploadSupplementEvent = MockUploadSupplementEventInteractor();
    mockSaveSupplementEvent = MockSaveSupplementEventInteractor();
    mockUploadSupplementFavorite = MockUploadSupplementFavoriteInteractor();
    mockSaveSupplementFavorite = MockSaveSupplementFavoriteInteractor();
    mockGetSupplementFavorites = MockGetSupplementFavoritesInteractor();
    mockUploadSupplementRoutine = MockUploadSupplementRoutineInteractor();
    mockSaveSupplementRoutine = MockSaveSupplementRoutineInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockGetRecentSupplementItems = MockGetRecentSupplementItemsInteractor();
  });

  SupplementsBloc buildBloc() => SupplementsBloc(
        getProfileInteractor: mockGetProfile,
        getMasterFileInteractor: mockGetMasterFile,
        uploadSupplementEventInteractor: mockUploadSupplementEvent,
        saveSupplementEventInteractor: mockSaveSupplementEvent,
        uploadSupplementFavoriteInteractor: mockUploadSupplementFavorite,
        saveSupplementFavoriteInteractor: mockSaveSupplementFavorite,
        getSupplementFavoritesInteractor: mockGetSupplementFavorites,
        uploadSupplementRoutineInteractor: mockUploadSupplementRoutine,
        saveSupplementRoutineInteractor: mockSaveSupplementRoutine,
        getUserIdInteractor: mockGetUserId,
        getRecentSupplementItemsInteractor: mockGetRecentSupplementItems,
      );

  group('SupplementsBloc', () {
    blocTest<SupplementsBloc, SupplementsState>(
      'initial state is not loading with empty supplement',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.supplementObj, isNotNull);
        expect(bloc.state.supplementObj!.info, isEmpty);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'InitializationSupplementsAction loads profile, supplements info, favorites, and recent items',
      build: () {
        when(mockGetProfile.execute())
            .thenAnswer((_) async => UserProfileModel());
        when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
            .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
        when(mockGetSupplementFavorites.execute())
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockGetRecentSupplementItems.execute())
            .thenAnswer((_) async => <SupplementSimple>[]);
        when(mockGetUserId.execute()).thenReturn('user123');
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializationSupplementsAction()),
      expect: () => [
        // isLoading: true
        isA<SupplementsState>().having((s) => s.isLoading, 'isLoading', true),
        // isLoading: false after data loaded
        isA<SupplementsState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetProfile.execute()).called(1);
        verify(mockGetMasterFile.execute(MasterFilesType.supplementsInfo)).called(1);
        verify(mockGetSupplementFavorites.execute()).called(1);
        verify(mockGetRecentSupplementItems.execute()).called(1);
        verify(mockGetUserId.execute()).called(1);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateScreenTitle sets screenTitle on state',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateScreenTitle(screenTitle: 'My Supplements')),
      verify: (bloc) {
        expect(bloc.state.screenTitle, 'My Supplements');
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateDateSupplementsAction sets eventDate on supplementObj',
      build: buildBloc,
      act: (bloc) {
        final date = DateTime(2026, 2, 15);
        bloc.add(UpdateDateSupplementsAction(dateTime: date));
      },
      verify: (bloc) {
        expect(bloc.state.supplementObj!.eventDate, DateTime(2026, 2, 15).millisecondsSinceEpoch);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateFavoriteActionSupplementsEvent sets isFavorite and clears isRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isFavorite, true);
        expect(bloc.state.supplementObj!.isRoutine, false);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateRoutineActionSupplementsEvent sets isRoutine and clears isFavorite',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isRoutine, true);
        expect(bloc.state.supplementObj!.isFavorite, false);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateRoutineActionSupplementsEvent auto-initializes scheduleTime when enabling routine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.scheduleTime, isNotNull);
        expect(bloc.state.supplementObj!.scheduleTime!.isNotEmpty, true);
        expect(bloc.state.supplementObj!.scheduleTime!.contains(':'), true);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateRoutineActionSupplementsEvent does not overwrite existing scheduleTime',
      build: () {
        final bloc = buildBloc();
        bloc.state.supplementObj!.scheduleTime = '08:30';
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.scheduleTime, '08:30');
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateNameSupplementsEvent sets name on supplementObj',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateNameSupplementsEvent(name: 'Vitamin D')),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.name, 'Vitamin D');
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateTimeOfDaySupplementsEvent sets scheduleTime',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateTimeOfDaySupplementsEvent(scheduleTime: '08:00')),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.scheduleTime, '08:00');
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateDaysOfWeekSupplementsEvent adds day to list',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateDaysOfWeekSupplementsEvent(weekDay: 1)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.daysOfWeek, contains(1));
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'UpdateDaysOfWeekSupplementsEvent toggles day off when already present',
      build: () {
        final bloc = buildBloc();
        bloc.state.supplementObj!.daysOfWeek = [1, 3];
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateDaysOfWeekSupplementsEvent(weekDay: 1)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.daysOfWeek, isNot(contains(1)));
        expect(bloc.state.supplementObj!.daysOfWeek, contains(3));
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'SavingEventSupplementsAction does nothing when info is empty',
      build: buildBloc,
      act: (bloc) => bloc.add(SavingEventSupplementsAction(onFinish: () {})),
      expect: () => [],
      verify: (bloc) {
        // No upload should be attempted when info list is empty
        verifyNever(mockUploadSupplementEvent.execute(any));
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'AddSupplementInfoSupplementsAction adds nutrient info',
      build: buildBloc,
      act: (bloc) => bloc.add(AddSupplementInfoSupplementsAction(
        nutriInfo: NutriInfo(id: 1, unit: 'mg', amount: 500),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.info!.length, 1);
        expect(bloc.state.supplementObj!.info!.first.id, 1);
        expect(bloc.state.supplementObj!.info!.first.amount, 500);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'preSelectRoutine from routines screen sets isRoutine and initializes scheduleTime',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateRoutineActionSupplementsEvent(isRoutine: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isRoutine, true);
        expect(bloc.state.supplementObj!.isFavorite, false);
        expect(bloc.state.supplementObj!.scheduleTime, isNotNull);
        expect(bloc.state.supplementObj!.scheduleTime!.contains(':'), true);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'preSelectFavorite from favorites screen sets isFavorite and clears isRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateFavoriteActionSupplementsEvent(isFavorite: true)),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isFavorite, true);
        expect(bloc.state.supplementObj!.isRoutine, false);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'initial state has favRecentTab = 0 (Recent)',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 0);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'SwitchFavRecentTabSupplementsAction updates favRecentTab in state',
      build: buildBloc,
      act: (bloc) => bloc.add(SwitchFavRecentTabSupplementsAction(tabIndex: 1)),
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 1);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'PrefillSupplementForRoutineEvent sets isRoutine true and isFavorite false',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSupplementForRoutineEvent(
        supplement: SupplementSimple(
          info: [NutriInfo(id: 1, unit: 'mg', amount: 500)],
          name: 'Creatine',
          isFavorite: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isRoutine, true);
        expect(bloc.state.supplementObj!.isFavorite, false);
        expect(bloc.state.supplementObj!.name, 'Creatine');
        expect(bloc.state.supplementObj!.info!.length, 1);
        expect(bloc.state.supplementObj!.daysOfWeek, isEmpty);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'PrefillSupplementForRoutineEvent preserves eventDate from current state',
      build: () {
        final bloc = buildBloc();
        bloc.state.supplementObj!.eventDate = DateTime(2026, 3, 15).millisecondsSinceEpoch;
        return bloc;
      },
      act: (bloc) => bloc.add(PrefillSupplementForRoutineEvent(
        supplement: SupplementSimple(
          info: [],
          name: 'Test',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isRoutine, true);
        expect(bloc.state.supplementObj!.eventDate, DateTime(2026, 3, 15).millisecondsSinceEpoch);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'PrefillSupplementForFavoriteEvent sets isFavorite true and isRoutine false',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSupplementForFavoriteEvent(
        supplement: SupplementSimple(
          info: [NutriInfo(id: 1, unit: 'mg', amount: 500)],
          name: 'Creatine',
          isRoutine: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isFavorite, true);
        expect(bloc.state.supplementObj!.isRoutine, false);
        expect(bloc.state.supplementObj!.name, 'Creatine');
        expect(bloc.state.supplementObj!.info!.length, 1);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'PrefillSupplementForFavoriteEvent preserves eventDate from current state',
      build: () {
        final bloc = buildBloc();
        bloc.state.supplementObj!.eventDate = DateTime(2026, 3, 15).millisecondsSinceEpoch;
        return bloc;
      },
      act: (bloc) => bloc.add(PrefillSupplementForFavoriteEvent(
        supplement: SupplementSimple(
          info: [],
          name: 'Test',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isFavorite, true);
        expect(bloc.state.supplementObj!.eventDate, DateTime(2026, 3, 15).millisecondsSinceEpoch);
      },
    );

    blocTest<SupplementsBloc, SupplementsState>(
      'PrefillSupplementForCustomizeEvent sets neither isFavorite nor isRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(PrefillSupplementForCustomizeEvent(
        supplement: SupplementSimple(
          info: [NutriInfo(id: 1, unit: 'mg', amount: 500)],
          name: 'Creatine',
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.supplementObj!.isFavorite, false);
        expect(bloc.state.supplementObj!.isRoutine, false);
        expect(bloc.state.supplementObj!.name, 'Creatine');
        expect(bloc.state.supplementObj!.info!.length, 1);
      },
    );
  });
}
