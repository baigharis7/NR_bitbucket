// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutrientsInfoEntityAdapter extends TypeAdapter<NutrientsInfoEntity> {
  @override
  final int typeId = 16;

  @override
  NutrientsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutrientsInfoEntity(
      id: fields[0] as int,
      name: fields[1] as String,
      unit: fields[2] as String,
      es: fields[3] as String,
      en: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NutrientsInfoEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.es)
      ..writeByte(4)
      ..write(obj.en);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutrientsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoEntity _$NutrientsInfoEntityFromJson(Map<String, dynamic> json) =>
    NutrientsInfoEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      es: json['es'] as String,
      en: json['en'] as String,
    );

Map<String, dynamic> _$NutrientsInfoEntityToJson(
        NutrientsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'es': instance.es,
      'en': instance.en,
    };
