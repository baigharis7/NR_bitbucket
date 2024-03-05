import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfileModel {
  String? userId;
  String? commonName;
  int? birthDate;
  SexType? sex;
  double? occupationActivityFactor;
  PhysicalCharacteristics? physicalCharacteristics;
  FemaleCharacteristics? femaleCharacteristics;
  MedicalSituation? medicalSituation;
  List<int>? foodAversions;
  int? dietType;
  Exclusions? exclusions;
  List<int>? intolerances;
  String? symptoms; // TODO -> Consider storing it in a different table or only in local and send it with each recommendation
  int? guts;
  List<int>? objectives;
  List<String>? micronutrients;
  UserRdas? userRdas;
  int? feces;
  int? urine;
  List<int>? recommededIds;
  int? kcal;

  UserProfileModel({
    this.userId,
    this.commonName,
    this.birthDate,
    this.sex,
    this.occupationActivityFactor,
    this.physicalCharacteristics,
    this.femaleCharacteristics,
    this.medicalSituation,
    this.foodAversions,
    this.dietType,
    this.exclusions,
    this.intolerances,
    this.symptoms,
    this.guts,
    this.objectives,
    this.micronutrients,
    this.userRdas,
    this.feces,
    this.urine,
    this.recommededIds,
    this.kcal,
  });

  UserProfileModel.empty() {
    userId = null;
    commonName = null;
    birthDate = null;
    sex = null;
    occupationActivityFactor = null;
    physicalCharacteristics = PhysicalCharacteristics();
    femaleCharacteristics = FemaleCharacteristics(menstruation: Menstruation());
    medicalSituation = MedicalSituation(commonDiseases: [], otherDiseases: []);
    foodAversions = [];
    dietType = 0;
    exclusions = Exclusions(exclusions: []);
    intolerances = [];
    symptoms = null;
    guts = null;
    objectives = [];
    micronutrients = [];
    userRdas = UserRdas(userRdas: []);
    feces = null;
    urine = null;
    kcal = null;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MedicalSituation{
    List<int>? commonDiseases;
    List<String>? otherDiseases;
    bool underPharmaceuticalTreatment;

    MedicalSituation({this.commonDiseases, this.otherDiseases, this.underPharmaceuticalTreatment = false});

    factory MedicalSituation.fromJson(Map<String, dynamic> json) => _$MedicalSituationFromJson(json);
    Map<String, dynamic> toJson() => _$MedicalSituationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PhysicalCharacteristics{
  double? height;
  double? weight;
  String? unit;
  int? bodyFat;
  int? waistMeasurement;

  PhysicalCharacteristics({
    this.height,
    this.weight,
    this.unit,
    this.bodyFat,
    this.waistMeasurement,
  });

  factory PhysicalCharacteristics.fromJson(Map<String, dynamic> json) => _$PhysicalCharacteristicsFromJson(json);
  Map<String, dynamic> toJson() => _$PhysicalCharacteristicsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FemaleCharacteristics{
  Menstruation? menstruation;

  FemaleCharacteristics({this.menstruation});

  factory FemaleCharacteristics.fromJson(Map<String, dynamic> json) => _$FemaleCharacteristicsFromJson(json);
  Map<String, dynamic> toJson() => _$FemaleCharacteristicsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Menstruation {
  int? regularity;
  int? daysOfCycle;
  int? lastStartDate;

  Menstruation({
    this.regularity,
    this.daysOfCycle,
    this.lastStartDate,
  });

  factory Menstruation.fromJson(Map<String, dynamic> json) => _$MenstruationFromJson(json);
  Map<String, dynamic> toJson() => _$MenstruationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Exclusions {
  List<int>? exclusions;

  Exclusions({this.exclusions});

  factory Exclusions.fromJson(Map<String, dynamic> json) => _$ExclusionsFromJson(json);
  Map<String, dynamic> toJson() => _$ExclusionsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserRdas {
  List<UserRda> userRdas;

  UserRdas({required this.userRdas});

  factory UserRdas.fromJson(Map<String, dynamic> json) => _$UserRdasFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdasToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserRda {
  String name;
  num rda;
  num ul;

  UserRda({required this.name, required this.rda, required this.ul});

  factory UserRda.fromJson(Map<String, dynamic> json) => _$UserRdaFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdaToJson(this);
}

enum SexType {
male, female
}

enum MenstruationRegularity {
regular, irregular, nothing // TODO -> Add in definitive version.
}


