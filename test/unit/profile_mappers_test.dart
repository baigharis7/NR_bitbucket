import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/profile_mappers.dart';

void main() {
  // Olatz / Luisa Desch / maddi: legacy female accounts whose DynamoDB profile
  // never had femaleCharacteristics. The 265 download-mapper fix produces a
  // non-null FemaleCharacteristics with an all-null Menstruation for them; the
  // save-mapper used to crash on `.menstruation!.regularity!`.
  group('mapToProfileEntity — female with no menstruation data', () {
    UserProfileModel _orphanFemale() => UserProfileModel.empty()
      ..userId = 'sub-78633ed3'
      ..commonName = 'Olatz'
      ..birthDate = DateTime(1990, 1, 1).millisecondsSinceEpoch
      ..sex = SexType.female
      ..occupationActivityFactor = 1.2
      ..objectives = const <int>[5, 48]
      ..physicalCharacteristics =
          PhysicalCharacteristics(unit: 1, height: 155, weight: 58)
      ..medicalSituation = MedicalSituation(
        commonDiseases: const <int>[],
        otherDiseases: const <String>[],
        underPharmaceuticalTreatment: false,
      )
      ..exclusions = Exclusions(exclusions: const <int>[])
      ..userRdas = UserRdas(userRdas: const <UserRda>[])
      // The download mapper produces this exact shape for legacy female
      // accounts: fc non-null, menstruation non-null, but every inner field
      // null. Save mapper must not crash on that.
      ..femaleCharacteristics = FemaleCharacteristics(
        menstruation: Menstruation(
          regularity: null,
          daysOfCycle: null,
          lastStartDate: null,
        ),
      );

    test('does not throw on orphan-content femaleCharacteristics', () {
      expect(() => mapToProfileEntity(_orphanFemale()), returnsNormally);
    });

    test('writes femaleCharacteristics through with null inner fields', () {
      final entity = mapToProfileEntity(_orphanFemale());
      expect(entity.femaleCharacteristics, isNotNull);
      expect(entity.femaleCharacteristics!.menstruation, isNotNull);
      expect(entity.femaleCharacteristics!.menstruation!.regularity, isNull);
      expect(entity.femaleCharacteristics!.menstruation!.daysOfCycle, isNull);
      expect(entity.femaleCharacteristics!.menstruation!.lastStartDate, isNull);
    });
  });

}
