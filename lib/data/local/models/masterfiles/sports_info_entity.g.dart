// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sports_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SportsInfoEntityAdapter extends TypeAdapter<SportsInfoEntity> {
  @override
  final int typeId = 26;

  @override
  SportsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportsInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<SportInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SportsInfoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.v)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SportInfoEntityAdapter extends TypeAdapter<SportInfoEntity> {
  @override
  final int typeId = 27;

  @override
  SportInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SportInfoEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
      mets: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SportInfoEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.en)
      ..writeByte(2)
      ..write(obj.es)
      ..writeByte(3)
      ..write(obj.mets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportsInfoEntity _$SportsInfoEntityFromJson(Map<String, dynamic> json) =>
    SportsInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => SportInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportsInfoEntityToJson(SportsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SportInfoEntity _$SportInfoEntityFromJson(Map<String, dynamic> json) =>
    SportInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
      mets: json['mets'] as int,
    );

Map<String, dynamic> _$SportInfoEntityToJson(SportInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'mets': instance.mets,
    };
