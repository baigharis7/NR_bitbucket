// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objectives_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectivesInfoMaster _$ObjectivesInfoMasterFromJson(
        Map<String, dynamic> json) =>
    ObjectivesInfoMaster(
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => ObjectiveInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      metabolicObjectives: (json['metabolicObjectives'] as List<dynamic>)
          .map((e) => ObjectiveInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyCompositionObjectives: (json['bodyCompositionObjectives'] as List<dynamic>)
          .map((e) => ObjectiveInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ObjectivesInfoMasterToJson(
        ObjectivesInfoMaster instance) =>
    <String, dynamic>{
      'objectives': instance.objectives.map((e) => e.toJson()).toList(),
      'metabolicObjectives': instance.metabolicObjectives.map((e) => e.toJson()).toList(),
      'bodyCompositionObjectives': instance.bodyCompositionObjectives.map((e) => e.toJson()).toList(),
    };

ObjectiveInfoMaster _$ObjectiveInfoMasterFromJson(Map<String, dynamic> json) =>
    ObjectiveInfoMaster(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ObjectiveInfoMasterToJson(
        ObjectiveInfoMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
