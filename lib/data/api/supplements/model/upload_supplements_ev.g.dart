// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplements_ev.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementsEv _$UploadSupplementsEvFromJson(Map<String, dynamic> json) =>
    UploadSupplementsEv(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventDate: (json['eventDate'] as num).toInt(),
      info: (json['info'] as List<dynamic>)
          .map((e) => UploadSupplementInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$UploadSupplementsEvToJson(
        UploadSupplementsEv instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'info': instance.info.map((e) => e.toJson()).toList(),
      'name': instance.name,
    };
