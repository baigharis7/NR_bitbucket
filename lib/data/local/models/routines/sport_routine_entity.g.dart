// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_routine_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportRoutineEntityAdapter extends TypeAdapter<SportRoutineEntity> {
  @override
  final int typeId = 57;

  @override
  SportRoutineEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportRoutineEntity(
      userId: fields[0] as String?,
      eventId: fields[1] as int?,
      eventDate: fields[8] as int?,
      comment: fields[2] as String?,
      sportName: fields[3] as String?,
      scheduleTime: fields[4] as String?,
      info: (fields[5] as List?)?.cast<SportRoutineInfoEntity>(),
      daysOfWeek: (fields[6] as List?)?.cast<int>(),
      timeZone: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportRoutineEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.sportName)
      ..writeByte(4)
      ..write(obj.scheduleTime)
      ..writeByte(5)
      ..write(obj.info)
      ..writeByte(6)
      ..write(obj.daysOfWeek)
      ..writeByte(7)
      ..write(obj.timeZone)
      ..writeByte(8)
      ..write(obj.eventDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportRoutineEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SportRoutineInfoEntityAdapter
    extends TypeAdapter<SportRoutineInfoEntity> {
  @override
  final int typeId = 58;

  @override
  SportRoutineInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportRoutineInfoEntity(
      id: fields[0] as num?,
      nameEn: fields[1] as String?,
      nameEs: fields[2] as String?,
      timeStart: fields[3] as num?,
      intensity: fields[4] as num?,
      minutes: fields[5] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, SportRoutineInfoEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameEn)
      ..writeByte(2)
      ..write(obj.nameEs)
      ..writeByte(3)
      ..write(obj.timeStart)
      ..writeByte(4)
      ..write(obj.intensity)
      ..writeByte(5)
      ..write(obj.minutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportRoutineInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportRoutineEntity _$SportRoutineEntityFromJson(Map<String, dynamic> json) =>
    SportRoutineEntity(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
      scheduleTime: json['scheduleTime'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map(
              (e) => SportRoutineInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SportRoutineEntityToJson(SportRoutineEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'scheduleTime': instance.scheduleTime,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'daysOfWeek': instance.daysOfWeek,
      'timeZone': instance.timeZone,
      'eventDate': instance.eventDate,
    };

SportRoutineInfoEntity _$SportRoutineInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportRoutineInfoEntity(
      id: json['id'] as num?,
      nameEn: json['nameEn'] as String?,
      nameEs: json['nameEs'] as String?,
      timeStart: json['timeStart'] as num?,
      intensity: json['intensity'] as num?,
      minutes: json['minutes'] as num?,
    );

Map<String, dynamic> _$SportRoutineInfoEntityToJson(
        SportRoutineInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameEs': instance.nameEs,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
