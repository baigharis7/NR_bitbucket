// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadUserProfile _$UploadUserProfileFromJson(Map<String, dynamic> json) =>
    UploadUserProfile(
      userId: json['userId'] as String?,
      commonName: json['commonName'] as String,
      birthDate: json['birthDate'] as int,
      sex: json['sex'] as int,
      occupationActivityFactor:
          (json['occupationActivityFactor'] as num).toDouble(),
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
      exclusions: json['exclusions'] as String?,
      intolerances: json['intolerances'] as String?,
      guts: json['guts'] as int?,
      objectives:
          (json['objectives'] as List<dynamic>).map((e) => e as int).toList(),
      micronutrients: (json['micronutrients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userRdas: (json['userRdas'] as List<dynamic>?)
          ?.map((e) => UserRda.fromJson(e as Map<String, dynamic>))
          .toList(),
      feces: json['feces'] as int?,
      urine: json['urine'] as int?,
      recommededIds: json['recommededIds'] as List<int>?,
      kcal: json['kcal'] as int?,
    );

Map<String, dynamic> _$UploadUserProfileToJson(UploadUserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'commonName': instance.commonName,
      'birthDate': instance.birthDate,
      'sex': instance.sex,
      'occupationActivityFactor': instance.occupationActivityFactor,
      'physicalCharacteristics': instance.physicalCharacteristics?.toJson(),
      'femaleCharacteristics': instance.femaleCharacteristics?.toJson(),
      'medicalSituation': instance.medicalSituation?.toJson(),
      'foodAversions': instance.foodAversions,
      'exclusions': instance.exclusions,
      'intolerances': instance.intolerances,
      'guts': instance.guts,
      'objectives': instance.objectives,
      'micronutrients': instance.micronutrients,
      'userRdas': instance.userRdas?.map((e) => e.toJson()).toList(),
      'feces': instance.feces,
      'urine': instance.urine,
      'recommededIds': instance.recommededIds,
      'kcal': instance.kcal,
    };

MedicalSituation _$MedicalSituationFromJson(Map<String, dynamic> json) =>
    MedicalSituation(
      commonDiseases: json['commonDiseases'] as String?,
      otherDiseases: (json['otherDiseases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
      height: double.parse((json['height']).toString()),
      weight: double.parse((json['weight']).toString()),
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
      regularity: json['regularity'] as int,
      daysOfCycle: json['daysOfCycle'] as int?,
      lastStartDate: json['lastStartDate'] as int?,
    );

Map<String, dynamic> _$MenstruationToJson(Menstruation instance) =>
    <String, dynamic>{
      'regularity': instance.regularity,
      'daysOfCycle': instance.daysOfCycle,
      'lastStartDate': instance.lastStartDate,
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
      n: json['n'] as String,
      rda: json['rda'] as num,
      ul: json['ul'] as num,
    );

Map<String, dynamic> _$UserRdaToJson(UserRda instance) => <String, dynamic>{
      'n': instance.n,
      'rda': instance.rda,
      'ul': instance.ul,
    };
