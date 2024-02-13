// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepsEntityAdapter extends TypeAdapter<StepsEntity> {
  @override
  final int typeId = 56;

  @override
  StepsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepsEntity(
      eventId: fields[0] as int?,
      initialSteps: fields[1] as int?,
      actualSteps: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, StepsEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.initialSteps)
      ..writeByte(3)
      ..write(obj.actualSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepsEntity _$StepsEntityFromJson(Map<String, dynamic> json) => StepsEntity(
      eventId: json['eventId'] as int?,
      initialSteps: json['initialSteps'] as int?,
      actualSteps: json['actualSteps'] as int?,
    );

Map<String, dynamic> _$StepsEntityToJson(StepsEntity instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'initialSteps': instance.initialSteps,
      'actualSteps': instance.actualSteps,
    };
