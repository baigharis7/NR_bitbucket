// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplements_ev.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementsEv _$UploadSupplementsEvFromJson(Map<String, dynamic> json) =>
    UploadSupplementsEv(
      userId: json['userId'] as String,
      eventId: json['eventId'] as int,
      eventDate: json['eventDate'] as int,
      info: (json['info'] as List<dynamic>)
          .map((e) => UploadSupplementInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UploadSupplementsEvToJson(UploadSupplementsEv instance) =>
    <String, dynamic>{
  'userId': instance.userId,
  'eventId': instance.eventId,
  'eventDate': instance.eventDate,
  'info': instance.info,
};

UploadSupplementInfo _$UploadSupplementInfoFromJson(Map<String, dynamic> json) =>
    UploadSupplementInfo(
      id: json['id'] as int,
      amount: json['amount'] as int,
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$UploadSupplementInfoToJson(UploadSupplementInfo instance) =>
    <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'unit': instance.unit,
};


