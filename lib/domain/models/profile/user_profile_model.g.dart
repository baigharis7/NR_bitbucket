// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      userId: json['userId'] as String?,
      commonName: json['commonName'] as String?,
      birthDate: json['birthDate'] as int?,
      sex: $enumDecodeNullable(_$SexTypeEnumMap, json['sex']),
      occupationActivityFactor:
          (json['occupationActivityFactor'] as num?)?.toDouble(),
      physicalCharacteristics: json['physicalCharacteristics'] == null
          ? null
          : PhysicalCharacteristics.fromJson(
              json['physicalCharacteristics'] as Map<String, dynamic>),
      femaleCharacteristics: json['femaleCharacteristics'] == null
          ? null
          : FemaleCharacteristics.fromJson(
              json['femaleCharacteristics'] as Map<String, dynamic>),
      medicalSituation: json['medicalSituation'] == null
          ? null
          : MedicalSituation.fromJson(
              json['medicalSituation'] as Map<String, dynamic>),
      foodAversions: (json['foodAversions'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      dietType: json['dietType'] as int?,
      exclusions: json['exclusions'] == null
          ? null
          : Exclusions.fromJson(json['exclusions'] as Map<String, dynamic>),
      intolerances: (json['intolerances'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      symptoms: json['symptoms'] as String?,
      guts: json['guts'] as int?,
      objectives:
          (json['objectives'] as List<dynamic>?)?.map((e) => e as int).toList(),
      micronutrients: (json['micronutrients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userRdas: json['userRdas'] == null
          ? null
          : UserRdas.fromJson(json['userRdas'] as Map<String, dynamic>),
      feces: json['feces'] as int?,
      urine: json['urine'] as int?,
      recommededIds: json['recommededIds'] as List<int>?,
      kcal: json['kcal'] as int?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'commonName': instance.commonName,
      'birthDate': instance.birthDate,
      'sex': _$SexTypeEnumMap[instance.sex],
      'occupationActivityFactor': instance.occupationActivityFactor,
      'physicalCharacteristics': instance.physicalCharacteristics?.toJson(),
      'femaleCharacteristics': instance.femaleCharacteristics?.toJson(),
      'medicalSituation': instance.medicalSituation?.toJson(),
      'foodAversions': instance.foodAversions,
      'dietType': instance.dietType,
      'exclusions': instance.exclusions?.toJson(),
      'intolerances': instance.intolerances,
      'symptoms': instance.symptoms,
      'guts': instance.guts,
      'objectives': instance.objectives,
      'micronutrients': instance.micronutrients,
      'userRdas': instance.userRdas?.toJson(),
      'feces': instance.feces,
      'urine': instance.urine,
      'recommededIds': instance.recommededIds,
      'kcal': instance.kcal,
    };

const _$SexTypeEnumMap = {
  SexType.male: 'male',
  SexType.female: 'female',
};

MedicalSituation _$MedicalSituationFromJson(Map<String, dynamic> json) =>
    MedicalSituation(
      commonDiseases: (json['commonDiseases'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      otherDiseases: (json['otherDiseases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      underPharmaceuticalTreatment:
          json['underPharmaceuticalTreatment'] as bool? ?? false,
    );

Map<String, dynamic> _$MedicalSituationToJson(MedicalSituation instance) =>
    <String, dynamic>{
      'commonDiseases': instance.commonDiseases,
      'otherDiseases': instance.otherDiseases,
      'underPharmaceuticalTreatment': instance.underPharmaceuticalTreatment,
    };

PhysicalCharacteristics _$PhysicalCharacteristicsFromJson(
        Map<String, dynamic> json) =>
    PhysicalCharacteristics(
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      unit: json['unit'] as String?,
      bodyFat: json['bodyFat'] as int?,
      waistMeasurement: json['waistMeasurement'] as int?,
    );

Map<String, dynamic> _$PhysicalCharacteristicsToJson(
        PhysicalCharacteristics instance) =>
    <String, dynamic>{
      'height': instance.height,
      'weight': instance.weight,
      'unit': instance.unit,
      'bodyFat': instance.bodyFat,
      'waistMeasurement': instance.waistMeasurement,
    };

FemaleCharacteristics _$FemaleCharacteristicsFromJson(
        Map<String, dynamic> json) =>
    FemaleCharacteristics(
      menstruation: json['menstruation'] == null
          ? null
          : Menstruation.fromJson(json['menstruation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FemaleCharacteristicsToJson(
        FemaleCharacteristics instance) =>
    <String, dynamic>{
      'menstruation': instance.menstruation?.toJson(),
    };

Menstruation _$MenstruationFromJson(Map<String, dynamic> json) => Menstruation(
      regularity: json['regularity'] as int?,
      daysOfCycle: json['daysOfCycle'] as int?,
      lastStartDate: json['lastStartDate'] as int?,
    );

Map<String, dynamic> _$MenstruationToJson(Menstruation instance) =>
    <String, dynamic>{
      'regularity': instance.regularity,
      'daysOfCycle': instance.daysOfCycle,
      'lastStartDate': instance.lastStartDate,
    };

Exclusions _$ExclusionsFromJson(Map<String, dynamic> json) => Exclusions(
      exclusions:
          (json['exclusions'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ExclusionsToJson(Exclusions instance) =>
    <String, dynamic>{
      'exclusions': instance.exclusions,
    };

UserRdas _$UserRdasFromJson(Map<String, dynamic> json) => UserRdas(
      userRdas: (json['userRdas'] as List<dynamic>)
          .map((e) => UserRda.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserRdasToJson(UserRdas instance) => <String, dynamic>{
      'userRdas': instance.userRdas.map((e) => e.toJson()).toList(),
    };

UserRda _$UserRdaFromJson(Map<String, dynamic> json) => UserRda(
      name: json['name'] as String,
      rda: json['rda'] as num,
      ul: json['ul'] as num,
    );

Map<String, dynamic> _$UserRdaToJson(UserRda instance) => <String, dynamic>{
      'name': instance.name,
      'rda': instance.rda,
      'ul': instance.ul,
    };
