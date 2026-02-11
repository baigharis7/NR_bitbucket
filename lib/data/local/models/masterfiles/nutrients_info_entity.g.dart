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
      v: fields[1] as int,
      data: (fields[2] as List).cast<NutrientInfoEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, NutrientsInfoEntity obj) {
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
      other is NutrientsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutrientInfoEntityAdapter extends TypeAdapter<NutrientInfoEntity> {
  @override
  final int typeId = 17;

  @override
  NutrientInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutrientInfoEntity(
      name: fields[0] as String,
      unit: fields[1] as String,
      es: fields[2] as String,
      en: fields[3] as String,
      description_es: fields[4] as String?,
      description_en: fields[5] as String?,
      foods_es: fields[6] as String?,
      foods_en: fields[7] as String?,
      abbr: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NutrientInfoEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.es)
      ..writeByte(3)
      ..write(obj.en)
      ..writeByte(4)
      ..write(obj.description_es)
      ..writeByte(5)
      ..write(obj.description_en)
      ..writeByte(6)
      ..write(obj.foods_es)
      ..writeByte(7)
      ..write(obj.foods_en)
      ..writeByte(8)
      ..write(obj.abbr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutrientInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoEntity _$NutrientsInfoEntityFromJson(Map<String, dynamic> json) =>
    NutrientsInfoEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => NutrientInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutrientsInfoEntityToJson(
        NutrientsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

NutrientInfoEntity _$NutrientInfoEntityFromJson(Map<String, dynamic> json) =>
    NutrientInfoEntity(
      name: json['name'] as String,
      unit: json['unit'] as String,
      es: json['es'] as String,
      en: json['en'] as String,
      description_es: json['description_es'] as String?,
      description_en: json['description_en'] as String?,
      foods_es: json['foods_es'] as String?,
      foods_en: json['foods_en'] as String?,
      abbr: json['abbr'] as String?,
    );

Map<String, dynamic> _$NutrientInfoEntityToJson(NutrientInfoEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unit': instance.unit,
      'es': instance.es,
      'en': instance.en,
      'description_es': instance.description_es,
      'description_en': instance.description_en,
      'foods_es': instance.foods_es,
      'foods_en': instance.foods_en,
      'abbr': instance.abbr,
    };
