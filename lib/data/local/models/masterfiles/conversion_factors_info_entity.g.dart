// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_factors_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversionFactorsInfoEntityAdapter
    extends TypeAdapter<ConversionFactorsInfoEntity> {
  @override
  final int typeId = 71;

  @override
  ConversionFactorsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionFactorsInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<ConversionFactorInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversionFactorsInfoEntity obj) {
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
      other is ConversionFactorsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversionFactorInfoEntityAdapter
    extends TypeAdapter<ConversionFactorInfoEntity> {
  @override
  final int typeId = 72;

  @override
  ConversionFactorInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionFactorInfoEntity(
      id: fields[0] as int,
      value: fields[1] as String,
      list: (fields[2] as List).cast<ConversionInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversionFactorInfoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionFactorInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversionInfoEntityAdapter extends TypeAdapter<ConversionInfoEntity> {
  @override
  final int typeId = 73;

  @override
  ConversionInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionInfoEntity(
      g: fields[0] as String,
      v: fields[1] as num,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionInfoEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.g)
      ..writeByte(1)
      ..write(obj.v);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionFactorsInfoEntity _$ConversionFactorsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorsInfoEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              ConversionFactorInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorsInfoEntityToJson(
        ConversionFactorsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactorInfoEntity _$ConversionFactorInfoEntityFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorInfoEntity(
      id: (json['id'] as num).toInt(),
      value: json['value'] as String,
      list: (json['list'] as List<dynamic>)
          .map((e) => ConversionInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorInfoEntityToJson(
        ConversionFactorInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'list': instance.list.map((e) => e.toJson()).toList(),
    };

ConversionInfoEntity _$ConversionInfoEntityFromJson(
        Map<String, dynamic> json) =>
    ConversionInfoEntity(
      g: json['g'] as String,
      v: json['v'] as num,
    );

Map<String, dynamic> _$ConversionInfoEntityToJson(
        ConversionInfoEntity instance) =>
    <String, dynamic>{
      'g': instance.g,
      'v': instance.v,
    };
