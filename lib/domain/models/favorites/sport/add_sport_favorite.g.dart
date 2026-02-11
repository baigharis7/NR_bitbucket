// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_sport_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddSportFavorite _$AddSportFavoriteFromJson(Map<String, dynamic> json) =>
    AddSportFavorite(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      title: json['title'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) => AddSportFavInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      scheduleTime: json['scheduleTime'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      isFavorite: json['isFavorite'] as bool?,
      isCreateRoutine: json['isCreateRoutine'] as bool?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$AddSportFavoriteToJson(AddSportFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'title': instance.title,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'scheduleTime': instance.scheduleTime,
      'daysOfWeek': instance.daysOfWeek,
      'isFavorite': instance.isFavorite,
      'isCreateRoutine': instance.isCreateRoutine,
      'timeZone': instance.timeZone,
    };

AddSportFavInfo _$AddSportFavInfoFromJson(Map<String, dynamic> json) =>
    AddSportFavInfo(
      id: (json['id'] as num?)?.toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: (json['timeStart'] as num?)?.toInt(),
      intensity: (json['intensity'] as num?)?.toInt(),
      minutes: (json['minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AddSportFavInfoToJson(AddSportFavInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
