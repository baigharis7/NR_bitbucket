// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CookingMethodsEntityAdapter extends TypeAdapter<CookingMethodsEntity> {
  @override
  final int typeId = 23;

  @override
  CookingMethodsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodsEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<CookingMethodGroupEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodsEntity obj) {
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
      other is CookingMethodsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CookingMethodGroupEntityAdapter
    extends TypeAdapter<CookingMethodGroupEntity> {
  @override
  final int typeId = 24;

  @override
  CookingMethodGroupEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodGroupEntity(
      g: fields[0] as String,
      m: (fields[1] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodGroupEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.g)
      ..writeByte(1)
      ..write(obj.m);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CookingMethodGroupEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsEntity _$CookingMethodsEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodGroupEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsEntityToJson(
        CookingMethodsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodGroupEntity _$CookingMethodGroupEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodGroupEntity(
      g: json['g'] as String,
      m: (json['m'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$CookingMethodGroupEntityToJson(
        CookingMethodGroupEntity instance) =>
    <String, dynamic>{
      'g': instance.g,
      'm': instance.m,
    };
