// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportEventEntityAdapter extends TypeAdapter<SportEventEntity> {
  @override
  final int typeId = 28;

  @override
  SportEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportEventEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      info: fields[2] as SportEventInfoEntity,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.info);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SportEventInfoEntityAdapter extends TypeAdapter<SportEventInfoEntity> {
  @override
  final int typeId = 29;

  @override
  SportEventInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportEventInfoEntity(
      id: fields[0] as int,
      intensity: fields[1] as int,
      minutes: fields[2] as int,
      kcal: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventInfoEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.intensity)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.kcal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportEventInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventEntity _$SportEventEntityFromJson(Map<String, dynamic> json) =>
    SportEventEntity(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      info: SportEventInfoEntity.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SportEventEntityToJson(SportEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'info': instance.info.toJson(),
    };

SportEventInfoEntity _$SportEventInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoEntity(
      id: json['id'] as int,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoEntityToJson(
        SportEventInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
    };
