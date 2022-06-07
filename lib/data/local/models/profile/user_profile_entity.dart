import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'user_profile_entity.g.dart';

@HiveType(typeId: HiveTypeIds.userProfileEntity)
class UserProfileEntity extends HiveObject {
  @HiveField(0) String? userId;
  @HiveField(1) late String commonName;
  @HiveField(2) late int birthDate;
  @HiveField(3) late int sex;
  @HiveField(4) late double occupationActivityFactor;
  @HiveField(5) PhysicalCharacteristics? physicalCharacteristics;
  @HiveField(6) FemaleCharacteristics? femaleCharacteristics;
  @HiveField(7) MedicalSituation? medicalSituation;
  @HiveField(8) List<int>? foodAversions;
  @HiveField(9) int? dietType;
  @HiveField(10) Exclusions? exclusions;
  @HiveField(11) List<int>? intolerances;
  @HiveField(12) String? symptoms; // TODO -> Consider storing it in a different table or only in local and send it with each recommendation
  @HiveField(13) int? guts;
  @HiveField(14) List<int> objectives;
  @HiveField(15) List<String>? micronutrients;

  static const boxName = 'profile';

  UserProfileEntity({
    required this.userId,
    required this.commonName,
    required this.birthDate,
    required this.sex,
    required this.occupationActivityFactor,
    this.physicalCharacteristics,
    this.femaleCharacteristics,
    this.medicalSituation,
    this.foodAversions,
    this.dietType,
    this.exclusions,
    this.intolerances,
    this.symptoms,
    this.guts,
    required this.objectives,
    this.micronutrients
  });

}

@HiveType(typeId: HiveTypeIds.medicalSituation)
class MedicalSituation{
  @HiveField(0) List<int> commonDiseases;
  @HiveField(1) List<String> otherDiseases;
  @HiveField(2) bool underPharmaceuticalTreatment;

  MedicalSituation({this.commonDiseases = const [], this.otherDiseases = const [], this.underPharmaceuticalTreatment = false});
}

@HiveType(typeId: HiveTypeIds.physicalCharacteristics)
class PhysicalCharacteristics{
  @HiveField(0) late int height;
  @HiveField(1) late int weight;
  @HiveField(2) int? bodyFat;
  @HiveField(3) int? waistMeasurement;

  PhysicalCharacteristics({
    required this.height,
    required this.weight,
    this.bodyFat,
    this.waistMeasurement
  });
}

@HiveType(typeId: HiveTypeIds.femaleCharacteristics)
class FemaleCharacteristics{
  @HiveField(0) Menstruation? menstruation;

  FemaleCharacteristics({this.menstruation});
}

@HiveType(typeId: HiveTypeIds.menstruation)
class Menstruation {
  @HiveField(0) int regularity;
  @HiveField(1) int? daysOfCycle;
  @HiveField(2) int? lastStartDate;

  Menstruation({
    required this.regularity,
    this.daysOfCycle,
    this.lastStartDate
  });
}

@HiveType(typeId: HiveTypeIds.exclusions)
class Exclusions {
  @HiveField(0) List<int> exclusions;

  Exclusions({this.exclusions = const []});
}

@HiveType(typeId: HiveTypeIds.sexType)
enum SexType {
  @HiveField(0) male, @HiveField(1) female
}

@HiveType(typeId: HiveTypeIds.menstruationRegularity)
enum MenstruationRegularity {
  @HiveField(0) regular, @HiveField(1) irregular, @HiveField(2) nothing // TODO -> Add in definitive version.
}


