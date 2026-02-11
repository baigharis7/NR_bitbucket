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
      sportName: fields[3] as String?,
      info: (fields[4] as List?)?.cast<SportEventInfoEntity>(),
      eventKcals: fields[5] as int?,
      eventId: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.sportName)
      ..writeByte(4)
      ..write(obj.info)
      ..writeByte(5)
      ..write(obj.eventKcals)
      ..writeByte(6)
      ..write(obj.eventId);
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
      intensity: fields[1] as int?,
      minutes: fields[2] as int,
      timeStart: fields[3] as int?,
      kcal: fields[4] as int?,
      name_en: fields[5] as String?,
      name_es: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportEventInfoEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.intensity)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.timeStart)
      ..writeByte(4)
      ..write(obj.kcal)
      ..writeByte(5)
      ..write(obj.name_en)
      ..writeByte(6)
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
      eventDate: (json['eventDate'] as num).toInt(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) => SportEventInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventKcals: (json['eventKcals'] as num?)?.toInt(),
      eventId: (json['eventId'] as num).toInt(),
    );

Map<String, dynamic> _$SportEventEntityToJson(SportEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'eventKcals': instance.eventKcals,
      'eventId': instance.eventId,
    };

SportEventInfoEntity _$SportEventInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoEntity(
      id: (json['id'] as num).toInt(),
      intensity: (json['intensity'] as num?)?.toInt(),
      minutes: (json['minutes'] as num).toInt(),
      timeStart: (json['timeStart'] as num?)?.toInt(),
      kcal: (json['kcal'] as num?)?.toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
    );

Map<String, dynamic> _$SportEventInfoEntityToJson(
        SportEventInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'timeStart': instance.timeStart,
      'kcal': instance.kcal,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
    };
