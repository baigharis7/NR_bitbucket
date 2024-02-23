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
      fields[0] as String?,
      fields[1] as int?,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as String?,
      (fields[5] as List?)?.cast<SportRoutineInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SportRoutineEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.sportName)
      ..writeByte(4)
      ..write(obj.routineTime)
      ..writeByte(5)
      ..write(obj.info);
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
      fields[0] as num?,
      fields[1] as String?,
      fields[2] as String?,
      fields[3] as num?,
      fields[4] as num?,
      fields[5] as num?,
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
      json['userId'] as String?,
      json['eventId'] as int?,
      json['comment'] as String?,
      json['sportName'] as String?,
      json['routineTime'] as String?,
      (json['info'] as List<dynamic>?)
          ?.map(
              (e) => SportRoutineInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportRoutineEntityToJson(SportRoutineEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'routineTime': instance.routineTime,
      'info': instance.info?.map((e) => e.toJson()).toList(),
    };

SportRoutineInfoEntity _$SportRoutineInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportRoutineInfoEntity(
      json['id'] as num?,
      json['nameEn'] as String?,
      json['nameEs'] as String?,
      json['timeStart'] as num?,
      json['intensity'] as num?,
      json['minutes'] as num?,
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
