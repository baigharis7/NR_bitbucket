// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_factors_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversionFactorsEntityAdapter
    extends TypeAdapter<ConversionFactorsEntity> {
  @override
  final int typeId = 69;

  @override
  ConversionFactorsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionFactorsEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<ConversionFactorEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversionFactorsEntity obj) {
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
      other is ConversionFactorsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversionFactorEntityAdapter
    extends TypeAdapter<ConversionFactorEntity> {
  @override
  final int typeId = 70;

  @override
  ConversionFactorEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionFactorEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionFactorEntity obj) {
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
      other is ConversionFactorEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionFactorsEntity _$ConversionFactorsEntityFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorsEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map(
              (e) => ConversionFactorEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorsEntityToJson(
        ConversionFactorsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactorEntity _$ConversionFactorEntityFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorEntity(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ConversionFactorEntityToJson(
        ConversionFactorEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
