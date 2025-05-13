// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oil_types_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OilTypesEntityAdapter extends TypeAdapter<OilTypesEntity> {
  @override
  final int typeId = 67;

  @override
  OilTypesEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OilTypesEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<OilTypeEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, OilTypesEntity obj) {
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
      other is OilTypesEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OilTypeEntityAdapter extends TypeAdapter<OilTypeEntity> {
  @override
  final int typeId = 68;

  @override
  OilTypeEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OilTypeEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OilTypeEntity obj) {
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
      other is OilTypeEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OilTypesEntity _$OilTypesEntityFromJson(Map<String, dynamic> json) =>
    OilTypesEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => OilTypeEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OilTypesEntityToJson(OilTypesEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

OilTypeEntity _$OilTypeEntityFromJson(Map<String, dynamic> json) =>
    OilTypeEntity(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$OilTypeEntityToJson(OilTypeEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
