// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CookingMethodsInfoEntityAdapter
    extends TypeAdapter<CookingMethodsInfoEntity> {
  @override
  final int typeId = 21;

  @override
  CookingMethodsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodsInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<CookingMethodInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodsInfoEntity obj) {
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
      other is CookingMethodsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CookingMethodInfoEntityAdapter
    extends TypeAdapter<CookingMethodInfoEntity> {
  @override
  final int typeId = 22;

  @override
  CookingMethodInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodInfoEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodInfoEntity obj) {
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
      other is CookingMethodInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsInfoEntity _$CookingMethodsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsInfoEntityToJson(
        CookingMethodsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodInfoEntity _$CookingMethodInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$CookingMethodInfoEntityToJson(
        CookingMethodInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
