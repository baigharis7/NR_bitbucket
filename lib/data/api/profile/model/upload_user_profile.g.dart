// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadUserProfile _$UploadUserProfileFromJson(Map<String, dynamic> json) =>
    UploadUserProfile(
      userId: json['userId'] as String?,
      commonName: json['commonName'] as String,
      birthDate: (json['birthDate'] as num).toInt(),
      sex: (json['sex'] as num).toInt(),
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
          ?.map((e) => (e as num).toInt())
          .toList(),
      exclusions: json['exclusions'] as String?,
      intolerances: json['intolerances'] as String?,
      guts: (json['guts'] as num?)?.toInt(),
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      micronutrients: (json['micronutrients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userAll: (json['userAll'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      temporaryMicronutrients: (json['temporaryMicronutrients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      temporaryAll: (json['temporaryAll'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userRdas: (json['userRdas'] as List<dynamic>?)
          ?.map((e) => UserRda.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommededIds: (json['recommededIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      kcal: (json['kcal'] as num?)?.toInt(),
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
      'userAll': instance.userAll,
      'temporaryMicronutrients': instance.temporaryMicronutrients,
      'temporaryAll': instance.temporaryAll,
      'userRdas': instance.userRdas?.map((e) => e.toJson()).toList(),
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
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      unit: (json['unit'] as num?)?.toInt(),
      bodyFat: (json['bodyFat'] as num?)?.toInt(),
      waistMeasurement: (json['waistMeasurement'] as num?)?.toInt(),
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
      regularity: (json['regularity'] as num).toInt(),
      daysOfCycle: (json['daysOfCycle'] as num?)?.toInt(),
      lastStartDate: (json['lastStartDate'] as num?)?.toInt(),
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
      upperLimit: json['upperLimit'] as num?,
    );

Map<String, dynamic> _$UserRdaToJson(UserRda instance) => <String, dynamic>{
      'n': instance.n,
      'rda': instance.rda,
      'ul': instance.ul,
      'upperLimit': instance.upperLimit,
    };
