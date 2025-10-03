// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterEventEntityAdapter extends TypeAdapter<WaterEventEntity> {
  @override
  final int typeId = 39;

  @override
  WaterEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterEventEntity(
      fields[0] as String?,
      fields[1] as int?,
      fields[2] as int?,
      fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WaterEventEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.qty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterEventEntity _$WaterEventEntityFromJson(Map<String, dynamic> json) =>
    WaterEventEntity(
      json['userId'] as String?,
      (json['eventDate'] as num?)?.toInt(),
      (json['eventId'] as num?)?.toInt(),
      (json['qty'] as num).toDouble(),
    );

Map<String, dynamic> _$WaterEventEntityToJson(WaterEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'qty': instance.qty,
    };
