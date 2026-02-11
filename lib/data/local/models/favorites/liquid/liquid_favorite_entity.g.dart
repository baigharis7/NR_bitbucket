// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liquid_favorite_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiquidFavoriteEntityAdapter extends TypeAdapter<LiquidFavoriteEntity> {
  @override
  final int typeId = 44;

  @override
  LiquidFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiquidFavoriteEntity(
      ingredients: (fields[0] as List).cast<LiquidInFavoriteEntity>(),
      drinks: (fields[1] as List).cast<LiquidInFavoriteEntity>(),
      comment: fields[2] as String?,
      mealTime: fields[3] as int,
      title: fields[4] as String,
      eventDate: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LiquidFavoriteEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ingredients)
      ..writeByte(1)
      ..write(obj.drinks)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.mealTime)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.eventDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LiquidInFavoriteEntityAdapter
    extends TypeAdapter<LiquidInFavoriteEntity> {
  @override
  final int typeId = 45;

  @override
  LiquidInFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiquidInFavoriteEntity(
      id: fields[0] as int,
      qty: fields[1] as int,
      unit: fields[2] as int,
      cookingMethod: fields[3] as int,
      unitsEquivalences: fields[4] as String?,
      name_en: fields[5] as String?,
      name_es: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LiquidInFavoriteEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.qty)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.cookingMethod)
      ..writeByte(4)
      ..write(obj.unitsEquivalences)
      ..writeByte(5)
      ..write(obj.name_en)
      ..writeByte(6)
      ..write(obj.name_es);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidInFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiquidFavoriteEntity _$LiquidFavoriteEntityFromJson(
        Map<String, dynamic> json) =>
    LiquidFavoriteEntity(
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
              (e) => LiquidInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map(
              (e) => LiquidInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: (json['mealTime'] as num).toInt(),
      title: json['title'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
    );

Map<String, dynamic> _$LiquidFavoriteEntityToJson(
        LiquidFavoriteEntity instance) =>
    <String, dynamic>{
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'title': instance.title,
      'eventDate': instance.eventDate,
    };

LiquidInFavoriteEntity _$LiquidInFavoriteEntityFromJson(
        Map<String, dynamic> json) =>
    LiquidInFavoriteEntity(
      id: (json['id'] as num).toInt(),
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
    );

Map<String, dynamic> _$LiquidInFavoriteEntityToJson(
        LiquidInFavoriteEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
    };
