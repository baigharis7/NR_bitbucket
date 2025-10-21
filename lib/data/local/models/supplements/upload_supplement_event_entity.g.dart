// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplement_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadSupplementEventEntityAdapter
    extends TypeAdapter<UploadSupplementEventEntity> {
  @override
  final int typeId = 65;

  @override
  UploadSupplementEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadSupplementEventEntity(
      userId: fields[0] as String?,
      eventId: fields[1] as int?,
      value: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UploadSupplementEventEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadSupplementEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementEventEntity _$UploadSupplementEventEntityFromJson(
        Map<String, dynamic> json) =>
    UploadSupplementEventEntity(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadSupplementEventEntityToJson(
        UploadSupplementEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'value': instance.value,
    };
