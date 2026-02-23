// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_oils_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CookingMethodsOilsInfoEntityAdapter
    extends TypeAdapter<CookingMethodsOilsInfoEntity> {
  @override
  final int typeId = 80;

  @override
  CookingMethodsOilsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodsOilsInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<CookingMethodOilInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodsOilsInfoEntity obj) {
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
      other is CookingMethodsOilsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CookingMethodOilInfoEntityAdapter
    extends TypeAdapter<CookingMethodOilInfoEntity> {
  @override
  final int typeId = 81;

  @override
  CookingMethodOilInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingMethodOilInfoEntity(
      id: fields[0] as int,
      name: fields[1] as String,
      percentage: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CookingMethodOilInfoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.percentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CookingMethodOilInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsOilsInfoEntity _$CookingMethodsOilsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsOilsInfoEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodOilInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsOilsInfoEntityToJson(
        CookingMethodsOilsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodOilInfoEntity _$CookingMethodOilInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodOilInfoEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CookingMethodOilInfoEntityToJson(
        CookingMethodOilInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'percentage': instance.percentage,
    };
