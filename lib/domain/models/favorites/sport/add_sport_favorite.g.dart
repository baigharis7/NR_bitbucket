// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_sport_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddSportFavorite _$AddSportFavoriteFromJson(Map<String, dynamic> json) =>
    AddSportFavorite(
      userId: json['userId'],
      eventId: json['eventId'],
      comment: json['comment'],
      sportName: json['sportName'],
      info: json['info'] == null
          ? []
          : List<AddSportFavInfo>.from(
              json['info']!.map((x) => AddSportFavInfo.fromJson(x))),
    );

Map<String, dynamic> _$AddSportFavoriteToJson(AddSportFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'info': instance.info == null
          ? []
          : List<dynamic>.from(instance.info!.map((x) => x.toJson())),
    };

AddSportFavInfo _$AddSportFavInfoFromJson(Map<String, dynamic> json) => AddSportFavInfo(
      id: json['id'],
      name_en: json['name_en'],
      name_es: json['name_es'],
      timeStart: json['timeStart'],
      intensity: json['intensity'],
      minutes: json['minutes'],
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
