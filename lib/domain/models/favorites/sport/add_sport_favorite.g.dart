// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_sport_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddSportFavorite _$AddSportFavoriteFromJson(Map<String, dynamic> json) =>
    AddSportFavorite(
      userId: json['userId'] as String?,
      eventDate: json['eventDate'] as int?,
      comment: json['comment'] as String?,
      title: json['title'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) => AddSportFavInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      routineTime: json['routineTime'] as String?,
    );

Map<String, dynamic> _$AddSportFavoriteToJson(AddSportFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'title': instance.title,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'routineTime': instance.routineTime,
    };

AddSportFavInfo _$AddSportFavInfoFromJson(Map<String, dynamic> json) =>
    AddSportFavInfo(
      id: json['id'] as int?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: json['timeStart'] as int?,
      intensity: json['intensity'] as int?,
      minutes: json['minutes'] as int?,
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
