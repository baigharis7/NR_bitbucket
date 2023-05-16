// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_favorite_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportFavoriteEntityAdapter extends TypeAdapter<SportFavoriteEntity> {
  @override
  final int typeId = 42;

  @override
  SportFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportFavoriteEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      id: fields[2] as int?,
      name_en: fields[3] as String?,
      name_es: fields[4] as String?,
      timeStart: fields[5] as String?,
      intensity: fields[6] as int?,
      minutes: fields[7] as int?,
      title: fields[8] as String?,
      comment: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SportFavoriteEntity obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name_en)
      ..writeByte(4)
      ..write(obj.name_es)
      ..writeByte(5)
      ..write(obj.timeStart)
      ..writeByte(6)
      ..write(obj.intensity)
      ..writeByte(7)
      ..write(obj.minutes)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.comment);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportFavoriteEntity _$SportFavoriteEntityFromJson(Map<String, dynamic> json) =>
    SportFavoriteEntity(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      id: json['id'] as int?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: json['timeStart'] as String?,
      intensity: json['intensity'] as int?,
      minutes: json['minutes'] as int?,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$SportFavoriteEntityToJson(
        SportFavoriteEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'title': instance.title,
      'comment': instance.comment,
    };
