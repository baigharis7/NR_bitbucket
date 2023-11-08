// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportEventEntityAdapter extends TypeAdapter<SportEventEntity> {
  @override
  final int typeId = 29;

  @override
  SportEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportEventEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      comment: fields[2] as String?,
      info: fields[3] as SportEventInfoEntity,
      eventKcal: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.info)
      ..writeByte(4)
      ..write(obj.eventKcal);
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
  final int typeId = 30;

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
      name_en: fields[4] as String?,
      name_es: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventInfoEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.intensity)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.kcal)
      ..writeByte(4)
      ..write(obj.name_en)
      ..writeByte(5)
      ..write(obj.name_es);
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
      comment: json['comment'] as String?,
      info: SportEventInfoEntity.fromJson(json['info'] as Map<String, dynamic>),
      eventKcal: json['eventKcal'] as int?,
    );

Map<String, dynamic> _$SportEventEntityToJson(SportEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'info': instance.info.toJson(),
      'eventKcal': instance.eventKcal,
    };

SportEventInfoEntity _$SportEventInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoEntity(
      id: json['id'] as int,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
    );

Map<String, dynamic> _$SportEventInfoEntityToJson(
        SportEventInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
    };
