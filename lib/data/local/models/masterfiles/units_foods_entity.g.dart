// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_foods_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitsFoodsEntityAdapter extends TypeAdapter<UnitsFoodsEntity> {
  @override
  final int typeId = 33;

  @override
  UnitsFoodsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitsFoodsEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<UnitFoodEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitsFoodsEntity obj) {
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
      other is UnitsFoodsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitFoodEntityAdapter extends TypeAdapter<UnitFoodEntity> {
  @override
  final int typeId = 34;

  @override
  UnitFoodEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitFoodEntity(
      id: fields[0] as int,
      units: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UnitFoodEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.units);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitFoodEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsFoodsEntity _$UnitsFoodsEntityFromJson(Map<String, dynamic> json) =>
    UnitsFoodsEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => UnitFoodEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsFoodsEntityToJson(UnitsFoodsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

UnitFoodEntity _$UnitFoodEntityFromJson(Map<String, dynamic> json) =>
    UnitFoodEntity(
      id: (json['id'] as num).toInt(),
      units: json['units'] as String,
    );

Map<String, dynamic> _$UnitFoodEntityToJson(UnitFoodEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'units': instance.units,
    };
