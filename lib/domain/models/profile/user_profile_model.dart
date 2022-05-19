class UserProfileModel {
  String? userId;
  late String commonName;
  late int birthDate;
  late SexType sex;
  late double occupationActivityFactor;
  PhysicalCharacteristics? physicalCharacteristics;
  FemaleCharacteristics? femaleCharacteristics;
  MedicalSituation? medicalSituation;
  List<int>? foodAversions;
  int? dietType;
  Exclusions? exclusions;
  List<int>? intolerances;
  String? symptoms; // TODO -> Consider storing it in a different table or only in local and send it with each recommendation
  int? guts;
  List<int> objectives;
  List<String>? micronutrients;

  UserProfileModel({
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

class MedicalSituation{
    List<int> commonDiseases;
    List<String> otherDiseases;
    bool underPharmaceuticalTreatment;

    MedicalSituation({this.commonDiseases = const [], this.otherDiseases = const [], this.underPharmaceuticalTreatment = false});
}

class PhysicalCharacteristics{
  late int height;
  late int weight;
  int? bodyFat;
  int? waistMeasurement;

  PhysicalCharacteristics({
    required this.height,
    required this.weight,
    this.bodyFat,
    this.waistMeasurement
  });
}

class FemaleCharacteristics{
  Menstruation? menstruation;

  FemaleCharacteristics({this.menstruation});
}

class Menstruation {
  int regularity;
  int? daysOfCycle;
  int? lastStartDate;

  Menstruation({
    required this.regularity,
    this.daysOfCycle,
    this.lastStartDate
  });
}

class Exclusions {
  List<int> exclusions;

  Exclusions({this.exclusions = const []});
}

enum SexType {
male, female
}

enum MenstruationRegularity {
regular, irregular, nothing // TODO -> Add in definitive version.
}


