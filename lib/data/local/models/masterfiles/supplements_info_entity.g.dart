// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplements_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplementsInfoEntityAdapter extends TypeAdapter<SupplementsInfoEntity> {
  @override
  final int typeId = 76;

  @override
  SupplementsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplementsInfoEntity(
      v: fields[0] as int,
      data: (fields[1] as List).cast<SupplementInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SupplementsInfoEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.v)
      ..writeByte(1)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupplementInfoEntityAdapter extends TypeAdapter<SupplementInfoEntity> {
  @override
  final int typeId = 77;

  @override
  SupplementInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplementInfoEntity(
      id: fields[0] as int,
      es: fields[1] as String,
      en: fields[2] as String,
      unit: fields[3] as String,
      computerName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplementInfoEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.es)
      ..writeByte(2)
      ..write(obj.en)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.computerName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementsInfoEntity _$SupplementsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SupplementsInfoEntity(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => SupplementInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SupplementsInfoEntityToJson(
        SupplementsInfoEntity instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SupplementInfoEntity _$SupplementInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SupplementInfoEntity(
      id: (json['id'] as num).toInt(),
      es: json['es'] as String,
      en: json['en'] as String,
      unit: json['unit'] as String,
      computerName: json['computer_name'] as String?,
    );

Map<String, dynamic> _$SupplementInfoEntityToJson(
        SupplementInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'es': instance.es,
      'en': instance.en,
      'unit': instance.unit,
      'computer_name': instance.computerName,
    };
