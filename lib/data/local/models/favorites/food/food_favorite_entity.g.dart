// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_favorite_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodFavoriteEntityAdapter extends TypeAdapter<FoodFavoriteEntity> {
  @override
  final int typeId = 40;

  @override
  FoodFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodFavoriteEntity(
      ingredients: (fields[0] as List).cast<FoodInFavoriteEntity>(),
      drinks: (fields[1] as List).cast<FoodInFavoriteEntity>(),
      comment: fields[2] as String?,
      mealTime: fields[3] as int,
      title: fields[4] as String,
      eventDate: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FoodFavoriteEntity obj) {
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
      other is FoodFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodInFavoriteEntityAdapter extends TypeAdapter<FoodInFavoriteEntity> {
  @override
  final int typeId = 41;

  @override
  FoodInFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodInFavoriteEntity(
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
  void write(BinaryWriter writer, FoodInFavoriteEntity obj) {
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
      other is FoodInFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodFavoriteEntity _$FoodFavoriteEntityFromJson(Map<String, dynamic> json) =>
    FoodFavoriteEntity(
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => FoodInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => FoodInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: json['mealTime'] as int,
      title: json['title'] as String,
      eventDate: json['eventDate'] as int,
    );

Map<String, dynamic> _$FoodFavoriteEntityToJson(FoodFavoriteEntity instance) =>
    <String, dynamic>{
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'title': instance.title,
      'eventDate': instance.eventDate,
    };

FoodInFavoriteEntity _$FoodInFavoriteEntityFromJson(
        Map<String, dynamic> json) =>
    FoodInFavoriteEntity(
      id: json['id'] as int,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      cookingMethod: json['cookingMethod'] as int,
      unitsEquivalences: json['unitsEquivalences'] as String?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
    );

Map<String, dynamic> _$FoodInFavoriteEntityToJson(
        FoodInFavoriteEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
    };
