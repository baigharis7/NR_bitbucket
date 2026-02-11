// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_feces_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadFecesEventEntityAdapter
    extends TypeAdapter<UploadFecesEventEntity> {
  @override
  final int typeId = 64;

  @override
  UploadFecesEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadFecesEventEntity(
      userId: fields[0] as String,
      eventId: fields[1] as int,
      fecesId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UploadFecesEventEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.fecesId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadFecesEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFecesEventEntity _$UploadFecesEventEntityFromJson(
        Map<String, dynamic> json) =>
    UploadFecesEventEntity(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      fecesId: (json['fecesId'] as num).toInt(),
    );

Map<String, dynamic> _$UploadFecesEventEntityToJson(
        UploadFecesEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'fecesId': instance.fecesId,
    };
