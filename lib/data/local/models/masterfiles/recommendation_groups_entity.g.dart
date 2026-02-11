// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_groups_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecommendationGroupsEntityAdapter
    extends TypeAdapter<RecommendationGroupsEntity> {
  @override
  final int typeId = 12;

  @override
  RecommendationGroupsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationGroupsEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<RecommendationGroupEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationGroupsEntity obj) {
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
      other is RecommendationGroupsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecommendationGroupEntityAdapter
    extends TypeAdapter<RecommendationGroupEntity> {
  @override
  final int typeId = 13;

  @override
  RecommendationGroupEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationGroupEntity(
      id: fields[0] as int,
      groups: (fields[1] as List).cast<String>(),
      size: fields[2] as int,
      en: fields[3] as String,
      es: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationGroupEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groups)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.en)
      ..writeByte(4)
      ..write(obj.es);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationGroupEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationGroupsEntity _$RecommendationGroupsEntityFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupsEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              RecommendationGroupEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationGroupsEntityToJson(
        RecommendationGroupsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

RecommendationGroupEntity _$RecommendationGroupEntityFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupEntity(
      id: (json['id'] as num).toInt(),
      groups:
          (json['groups'] as List<dynamic>).map((e) => e as String).toList(),
      size: (json['size'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$RecommendationGroupEntityToJson(
        RecommendationGroupEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groups': instance.groups,
      'size': instance.size,
      'en': instance.en,
      'es': instance.es,
    };
