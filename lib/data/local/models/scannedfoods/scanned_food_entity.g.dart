// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_food_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannedFoodEntityAdapter extends TypeAdapter<ScannedFoodEntity> {
  @override
  final int typeId = 85;

  @override
  ScannedFoodEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScannedFoodEntity(
      lookupKey: fields[0] as String,
      localFoodId: fields[1] as int,
      nameEn: fields[2] as String,
      brand: fields[3] as String?,
      source: fields[4] as String,
      paramsJson: fields[5] as String,
      scannedAt: fields[6] as int,
      detectionMethod: fields[7] as String,
      isBeverage: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ScannedFoodEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.lookupKey)
      ..writeByte(1)
      ..write(obj.localFoodId)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.paramsJson)
      ..writeByte(6)
      ..write(obj.scannedAt)
      ..writeByte(7)
      ..write(obj.detectionMethod)
      ..writeByte(8)
      ..write(obj.isBeverage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedFoodEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedFoodEntity _$ScannedFoodEntityFromJson(Map<String, dynamic> json) =>
    ScannedFoodEntity(
      lookupKey: json['lookupKey'] as String,
      localFoodId: (json['localFoodId'] as num).toInt(),
      nameEn: json['nameEn'] as String,
      brand: json['brand'] as String?,
      source: json['source'] as String,
      paramsJson: json['paramsJson'] as String,
      scannedAt: (json['scannedAt'] as num).toInt(),
      detectionMethod: json['detectionMethod'] as String,
      isBeverage: json['isBeverage'] as bool? ?? false,
    );

Map<String, dynamic> _$ScannedFoodEntityToJson(ScannedFoodEntity instance) =>
    <String, dynamic>{
      'lookupKey': instance.lookupKey,
      'localFoodId': instance.localFoodId,
      'nameEn': instance.nameEn,
      'brand': instance.brand,
      'source': instance.source,
      'paramsJson': instance.paramsJson,
      'scannedAt': instance.scannedAt,
      'detectionMethod': instance.detectionMethod,
      'isBeverage': instance.isBeverage,
    };
