// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsObjective _$NutrientsObjectiveFromJson(Map<String, dynamic> json) =>
    NutrientsObjective(
      nutrients: (json['nutrients'] as List<dynamic>?)
          ?.map((e) => NutrientInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutrientsObjectiveToJson(NutrientsObjective instance) =>
    <String, dynamic>{
      'nutrients': instance.nutrients?.map((e) => e.toJson()).toList(),
    };

NutrientInfo _$NutrientInfoFromJson(Map<String, dynamic> json) => NutrientInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
      sol: json['sol'] as int?,
      unit: json['unit'] as String?,
      convFactor: (json['convFactor'] as num?)?.toDouble(),
      male1: (json['male1'] as num?)?.toDouble(),
      male2: (json['male2'] as num?)?.toDouble(),
      male3: (json['male3'] as num?)?.toDouble(),
      male4: (json['male4'] as num?)?.toDouble(),
      female1: (json['female1'] as num?)?.toDouble(),
      female2: (json['female2'] as num?)?.toDouble(),
      female3: (json['female3'] as num?)?.toDouble(),
      female4: (json['female4'] as num?)?.toDouble(),
      pregnancy1: (json['pregnancy1'] as num?)?.toDouble(),
      pregnancy2: (json['pregnancy2'] as num?)?.toDouble(),
      lactancy1: (json['lactancy1'] as num?)?.toDouble(),
      lactancy2: (json['lactancy2'] as num?)?.toDouble(),
      ulMale1: (json['ulMale1'] as num?)?.toDouble(),
      ulMale2: (json['ulMale2'] as num?)?.toDouble(),
      ulMale3: (json['ulMale3'] as num?)?.toDouble(),
      ulFemale1: (json['ulFemale1'] as num?)?.toDouble(),
      ulFemale2: (json['ulFemale2'] as num?)?.toDouble(),
      ulFemale3: (json['ulFemale3'] as num?)?.toDouble(),
      ulPregnancy: (json['ulPregnancy'] as num?)?.toDouble(),
      objectives:
          (json['objectives'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$NutrientInfoToJson(NutrientInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sol': instance.sol,
      'unit': instance.unit,
      'convFactor': instance.convFactor,
      'male1': instance.male1,
      'male2': instance.male2,
      'male3': instance.male3,
      'male4': instance.male4,
      'female1': instance.female1,
      'female2': instance.female2,
      'female3': instance.female3,
      'female4': instance.female4,
      'pregnancy1': instance.pregnancy1,
      'pregnancy2': instance.pregnancy2,
      'lactancy1': instance.lactancy1,
      'lactancy2': instance.lactancy2,
      'ulMale1': instance.ulMale1,
      'ulMale2': instance.ulMale2,
      'ulMale3': instance.ulMale3,
      'ulFemale1': instance.ulFemale1,
      'ulFemale2': instance.ulFemale2,
      'ulFemale3': instance.ulFemale3,
      'ulPregnancy': instance.ulPregnancy,
      'objectives': instance.objectives,
    };
