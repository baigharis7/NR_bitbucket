// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_favorite_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportFavoriteEntityAdapter extends TypeAdapter<SportFavoriteEntity> {
  @override
  final int typeId = 54;

  @override
  SportFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportFavoriteEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      title: fields[2] as String?,
      comment: fields[3] as String?,
      info: (fields[4] as List?)?.cast<SportFavoriteInfoEntity>(),
      eventId: fields[5] as int?,
      scheduleTime: fields[6] as String?,
      daysOfWeek: (fields[7] as List?)?.cast<int>(),
      isFavorite: fields[8] as bool?,
      isCreateRoutine: fields[9] as bool?,
      timeZone: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportFavoriteEntity obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.info)
      ..writeByte(5)
      ..write(obj.eventId)
      ..writeByte(6)
      ..write(obj.scheduleTime)
      ..writeByte(7)
      ..write(obj.daysOfWeek)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.isCreateRoutine)
      ..writeByte(10)
      ..write(obj.timeZone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SportFavoriteInfoEntityAdapter
    extends TypeAdapter<SportFavoriteInfoEntity> {
  @override
  final int typeId = 55;

  @override
  SportFavoriteInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportFavoriteInfoEntity(
      id: fields[0] as int?,
      intensity: fields[1] as int?,
      minutes: fields[2] as int?,
      timeStart: fields[3] as int?,
      name_en: fields[4] as String?,
      name_es: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportFavoriteInfoEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.intensity)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.timeStart)
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
      other is SportFavoriteInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportFavoriteEntity _$SportFavoriteEntityFromJson(Map<String, dynamic> json) =>
    SportFavoriteEntity(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) =>
              SportFavoriteInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventId: (json['eventId'] as num?)?.toInt(),
      scheduleTime: json['scheduleTime'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      isFavorite: json['isFavorite'] as bool?,
      isCreateRoutine: json['isCreateRoutine'] as bool?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SportFavoriteEntityToJson(
        SportFavoriteEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'title': instance.title,
      'comment': instance.comment,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'eventId': instance.eventId,
      'scheduleTime': instance.scheduleTime,
      'daysOfWeek': instance.daysOfWeek,
      'isFavorite': instance.isFavorite,
      'isCreateRoutine': instance.isCreateRoutine,
      'timeZone': instance.timeZone,
    };

SportFavoriteInfoEntity _$SportFavoriteInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SportFavoriteInfoEntity(
      id: (json['id'] as num?)?.toInt(),
      intensity: (json['intensity'] as num?)?.toInt(),
      minutes: (json['minutes'] as num?)?.toInt(),
      timeStart: (json['timeStart'] as num?)?.toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
    );

Map<String, dynamic> _$SportFavoriteInfoEntityToJson(
        SportFavoriteInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'timeStart': instance.timeStart,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
    };
