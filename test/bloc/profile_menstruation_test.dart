import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

UserProfileResponse _success() => UserProfileResponse(
      uploadSuccess: true,
      micronutrients: const [],
      userAll: const [],
      temporaryMicronutrients: const [],
      temporaryAll: const [],
      userRdas: const [],
      kcal: 2000,
    );

void main() {
  late MockGetProfileInteractor mockGetProfile;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetUserIdInteractor mockGetUserId;
  late MockUploadProfileInteractor mockUploadProfile;
  late MockSaveProfileInteractor mockSaveProfile;
  late MockSignOutInteractor mockSignOut;
  late MockEraseDatabaseInteractor mockEraseDb;
  late MockClearAuthPreferencesInteractor mockClearAuth;

  setUp(() {
    mockGetProfile = MockGetProfileInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockUploadProfile = MockUploadProfileInteractor();
    mockSaveProfile = MockSaveProfileInteractor();
    mockSignOut = MockSignOutInteractor();
    mockEraseDb = MockEraseDatabaseInteractor();
    mockClearAuth = MockClearAuthPreferencesInteractor();

    when(mockGetProfile.execute())
        .thenAnswer((_) async => UserProfileModel.empty());
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo)).thenAnswer(
      (_) async => ObjectivesInfoMaster(
        objectives: [ObjectiveInfoMaster(id: 1, en: 'Obj 1', es: 'Obj 1')],
        metabolicObjectives: const [],
        bodyCompositionObjectives: const [],
      ),
    );
    when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
        .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
              FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
            ));
    when(mockGetMasterFile.execute(MasterFilesType.recommendationGroups))
        .thenAnswer((_) async =>
            RecommendationGroupsMaster(recommendationGroups: const []));
    when(mockUploadProfile.execute(any)).thenAnswer((_) async => _success());
    when(mockSaveProfile.execute(any)).thenAnswer((_) async {});
  });

  ProfileBloc buildBloc({required bool female}) {
    final bloc = ProfileBloc(
      getProfileInteractor: mockGetProfile,
      getMasterFileInteractor: mockGetMasterFile,
      getUserIdInteractor: mockGetUserId,
      uploadProfileInteractor: mockUploadProfile,
      saveProfileInteractor: mockSaveProfile,
      signOutInteractor: mockSignOut,
      eraseDatabaseInteractor: mockEraseDb,
      clearAuthPreferencesInteractor: mockClearAuth,
    );
    bloc.state.profile = UserProfileModel.empty()
      ..commonName = 'Olatz'
      ..birthDate = DateTime(1990, 1, 1).millisecondsSinceEpoch
      ..sex = female ? SexType.female : SexType.male
      ..objectives = <int>[1]
      ..physicalCharacteristics =
          PhysicalCharacteristics(unit: 1, height: 155, weight: 58);
    return bloc;
  }

  group('Menstruation flow', () {
    test('SetPeriodRegularityAction populates femaleCharacteristics', () async {
      final bloc = buildBloc(female: true);
      bloc.add(SetPeriodRegularityAction(
        periodRegularity: MenstruationRegularity.regular.index,
      ));
      // Let the event handler run
      await Future<void>.delayed(Duration.zero);

      final fc = bloc.state.profile!.femaleCharacteristics;
      expect(fc, isNotNull);
      expect(fc!.menstruation!.regularity,
          MenstruationRegularity.regular.index);
    });

    test('ClearMenstruationAction wipes femaleCharacteristics back to null',
        () async {
      final bloc = buildBloc(female: true);
      // First select something
      bloc.add(SetPeriodRegularityAction(
        periodRegularity: MenstruationRegularity.irregular.index,
      ));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.profile!.femaleCharacteristics, isNotNull);

      // Then skip
      bloc.add(ClearMenstruationAction());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.profile!.femaleCharacteristics, isNull);
    });

    test(
        'FinishProfileAction omits femaleCharacteristics when regularity unset',
        () async {
      final bloc = buildBloc(female: true);
      // Simulate Skip For Now: no regularity chosen.
      bloc.add(ClearMenstruationAction());
      await Future<void>.delayed(Duration.zero);

      bool finished = false;
      bloc.add(FinishProfileAction(nextScreen: () => finished = true));
      // Let upload + save resolve
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(finished, isTrue);
      // The uploaded profile model carries femaleCharacteristics = null
      final captured = verify(mockUploadProfile.execute(captureAny)).captured;
      final uploaded = captured.single as UserProfileModel;
      expect(uploaded.sex, SexType.female);
      expect(uploaded.femaleCharacteristics, isNull);
    });

    test('FinishProfileAction keeps femaleCharacteristics for male unchanged',
        () async {
      final bloc = buildBloc(female: false);
      bool finished = false;
      bloc.add(FinishProfileAction(nextScreen: () => finished = true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(finished, isTrue);
      final captured = verify(mockUploadProfile.execute(captureAny)).captured;
      final uploaded = captured.single as UserProfileModel;
      expect(uploaded.sex, SexType.male);
      expect(uploaded.femaleCharacteristics, isNull);
    });
  });
}
