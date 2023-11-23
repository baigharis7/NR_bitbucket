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
    );
  }

  @override
  void write(BinaryWriter writer, SportFavoriteEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.info);
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

class SportFavoriteInfoEntityAdapter extends TypeAdapter<SportFavoriteInfoEntity> {
  @override
  SportFavoriteInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };
    return SportFavoriteInfoEntity(
        id: fields[0] as int,
        intensity: fields[1] as int,
        minutes: fields[2] as int,
        timeStart: fields[3] as int,
        name_en: fields[4] as String,
        name_es: fields[5] as String,
    );
  }

  @override
  int get typeId => 55;

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
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportFavoriteEntity _$SportFavoriteEntityFromJson(Map<String, dynamic> json) =>
    SportFavoriteEntity(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      comment: json['comment'] as String,
      title: json['title'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) =>
          SportFavoriteInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportFavoriteEntityToJson(
    SportFavoriteEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'title': instance.title,
      'info': instance.info?.map((e) => e.toJson()).toList(),
    };

SportFavoriteInfoEntity _$SportFavoriteInfoEntityFromJson(
    Map<String, dynamic> json) =>
    SportFavoriteInfoEntity(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      timeStart: json['timeStart'] as int,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
    );

Map<String, dynamic> _$SportFavoriteInfoEntityToJson(
    SportFavoriteInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };

