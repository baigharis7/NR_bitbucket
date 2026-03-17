// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepEventEntityAdapter extends TypeAdapter<SleepEventEntity> {
  @override
  final int typeId = 84;

  @override
  SleepEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepEventEntity(
      userId: fields[0] as String?,
      eventDate: fields[1] as int,
      eventId: fields[2] as int,
      sleepMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SleepEventEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.sleepMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepEventEntity _$SleepEventEntityFromJson(Map<String, dynamic> json) =>
    SleepEventEntity(
      userId: json['userId'] as String?,
      eventDate: (json['eventDate'] as num).toInt(),
      eventId: (json['eventId'] as num).toInt(),
      sleepMinutes: (json['sleepMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$SleepEventEntityToJson(SleepEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'sleepMinutes': instance.sleepMinutes,
    };
