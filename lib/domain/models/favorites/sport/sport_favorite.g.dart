// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportFavorite _$SportFavoriteFromJson(Map<String, dynamic> json) =>
    SportFavorite(
      id: (json['id'] as num?)?.toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: json['timeStart'] as String?,
      intensity: (json['intensity'] as num?)?.toInt(),
      minutes: (json['minutes'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$SportFavoriteToJson(SportFavorite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'eventDate': instance.eventDate,
      'title': instance.title,
      'comment': instance.comment,
    };
