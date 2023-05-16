// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objectives_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObjectivesInfoEntityAdapter extends TypeAdapter<ObjectivesInfoEntity> {
  @override
  final int typeId = 14;

  @override
  ObjectivesInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObjectivesInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<ObjectiveInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, ObjectivesInfoEntity obj) {
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
      other is ObjectivesInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ObjectiveInfoEntityAdapter extends TypeAdapter<ObjectiveInfoEntity> {
  @override
  final int typeId = 15;

  @override
  ObjectiveInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObjectiveInfoEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ObjectiveInfoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.en)
      ..writeByte(2)
      ..write(obj.es);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectiveInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectivesInfoEntity _$ObjectivesInfoEntityFromJson(
        Map<String, dynamic> json) =>
    ObjectivesInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => ObjectiveInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ObjectivesInfoEntityToJson(
        ObjectivesInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ObjectiveInfoEntity _$ObjectiveInfoEntityFromJson(Map<String, dynamic> json) =>
    ObjectiveInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ObjectiveInfoEntityToJson(
        ObjectiveInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
