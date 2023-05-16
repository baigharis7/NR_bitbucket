import 'package:json_annotation/json_annotation.dart';

part 'upload_user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadUserProfile {
  String? userId;
  late String commonName;
  late int birthDate;
  late int sex;
  late double occupationActivityFactor;
  PhysicalCharacteristics? physicalCharacteristics;
  FemaleCharacteristics? femaleCharacteristics;
  MedicalSituation? medicalSituation;
  List<int>? foodAversions;
  String? exclusions;
  String? intolerances;
  // String? symptoms; // TODO -> Consider storing it in a different table or only in local and send it with each recommendation
  int? guts;
  List<int> objectives;
  List<String>? micronutrients;
  List<UserRda>? userRdas;
  int? kcal;

  UploadUserProfile({
    required this.userId,
    required this.commonName,
    required this.birthDate,
    required this.sex,
    required this.occupationActivityFactor,
    this.physicalCharacteristics,
    this.femaleCharacteristics,
    this.medicalSituation,
    this.foodAversions,
    this.exclusions,
    this.intolerances,
    // this.symptoms,
    this.guts,
    required this.objectives,
    this.micronutrients,
    this.userRdas,
    this.kcal,
  });

  factory UploadUserProfile.fromJson(Map<String, dynamic> json) => _$UploadUserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UploadUserProfileToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MedicalSituation{
  String? commonDiseases;
  List<String>? otherDiseases;
  bool underPharmaceuticalTreatment;

  MedicalSituation({this.commonDiseases, this.otherDiseases = const [], this.underPharmaceuticalTreatment = false});

  factory MedicalSituation.fromJson(Map<String, dynamic> json) => _$MedicalSituationFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalSituationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PhysicalCharacteristics{
  late int height;
  late int weight;
  int? bodyFat;
  int? waistMeasurement;

  PhysicalCharacteristics({
    required this.height,
    required this.weight,
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
  int regularity;
  int? daysOfCycle;
  int? lastStartDate;

  Menstruation({
    required this.regularity,
    this.daysOfCycle,
    this.lastStartDate,
  });

  factory Menstruation.fromJson(Map<String, dynamic> json) => _$MenstruationFromJson(json);
  Map<String, dynamic> toJson() => _$MenstruationToJson(this);
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
  String n;
  num rda;
  num ul;

  UserRda({required this.n, required this.rda, required this.ul});

  factory UserRda.fromJson(Map<String, dynamic> json) => _$UserRdaFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdaToJson(this);
}

enum SexType {
  male, female
}

enum MenstruationRegularity {
  regular, irregular, nothing // TODO -> Add in definitive version.
}