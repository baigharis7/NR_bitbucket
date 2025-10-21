// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitsInfoEntityAdapter extends TypeAdapter<UnitsInfoEntity> {
  @override
  final int typeId = 31;

  @override
  UnitsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitsInfoEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<UnitInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitsInfoEntity obj) {
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
      other is UnitsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitInfoEntityAdapter extends TypeAdapter<UnitInfoEntity> {
  @override
  final int typeId = 32;

  @override
  UnitInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitInfoEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
      enPlural: fields[3] as String?,
      esPlural: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UnitInfoEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.en)
      ..writeByte(2)
      ..write(obj.es)
      ..writeByte(3)
      ..write(obj.enPlural)
      ..writeByte(4)
      ..write(obj.esPlural);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsInfoEntity _$UnitsInfoEntityFromJson(Map<String, dynamic> json) =>
    UnitsInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => UnitInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsInfoEntityToJson(UnitsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

UnitInfoEntity _$UnitInfoEntityFromJson(Map<String, dynamic> json) =>
    UnitInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
      enPlural: json['enPlural'] as String?,
      esPlural: json['esPlural'] as String?,
    );

Map<String, dynamic> _$UnitInfoEntityToJson(UnitInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'enPlural': instance.enPlural,
      'esPlural': instance.esPlural,
    };
