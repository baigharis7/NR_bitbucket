// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventSimple _$SportEventSimpleFromJson(Map<String, dynamic> json) =>
    SportEventSimple(
      userId: json['userId'] as String?,
      info: json['info'] == null
          ? null
          : SportInfo.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SportEventSimpleToJson(SportEventSimple instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'info': instance.info?.toJson(),
    };

SportInfo _$SportInfoFromJson(Map<String, dynamic> json) => SportInfo(
      id: json['id'] as int?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: json['timeStart'] as int?,
      intensity: json['intensity'] as int?,
      minutes: json['minutes'] as int?,
    );

Map<String, dynamic> _$SportInfoToJson(SportInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
