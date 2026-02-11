// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_feces.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFeces _$UploadFecesFromJson(Map<String, dynamic> json) => UploadFeces(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      fecesId: (json['fecesId'] as num).toInt(),
    );

Map<String, dynamic> _$UploadFecesToJson(UploadFeces instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'fecesId': instance.fecesId,
    };
