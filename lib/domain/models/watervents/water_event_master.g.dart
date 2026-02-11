// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_event_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterEventMaster _$WaterEventMasterFromJson(Map<String, dynamic> json) =>
    WaterEventMaster(
      json['userId'] as String?,
      (json['eventDate'] as num?)?.toInt(),
      (json['eventId'] as num?)?.toInt(),
      (json['qty'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WaterEventMasterToJson(WaterEventMaster instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'qty': instance.qty,
    };
