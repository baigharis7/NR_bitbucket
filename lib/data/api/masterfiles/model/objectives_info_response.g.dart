// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objectives_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectivesInfoResponse _$ObjectivesInfoResponseFromJson(
        Map<String, dynamic> json) =>
    ObjectivesInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => ObjectiveInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      metabolicObjectives: (json['metabolicObjectives'] as List<dynamic>)
          .map((e) => ObjectiveInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyCompositionObjectives: (json['bodyCompositionObjectives'] as List<dynamic>)
          .map((e) => ObjectiveInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ObjectivesInfoResponseToJson(
        ObjectivesInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
      'metabolicObjectives': instance.metabolicObjectives.map((e) => e.toJson()).toList(),
      'bodyCompositionObjectives': instance.bodyCompositionObjectives.map((e) => e.toJson()).toList(),
    };

ObjectiveInfo _$ObjectiveInfoFromJson(Map<String, dynamic> json) =>
    ObjectiveInfo(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ObjectiveInfoToJson(ObjectiveInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
