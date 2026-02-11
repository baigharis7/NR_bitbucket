// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foods_and_drinks_names_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodsAndDrinksNamesEntityAdapter
    extends TypeAdapter<FoodsAndDrinksNamesEntity> {
  @override
  final int typeId = 18;

  @override
  FoodsAndDrinksNamesEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodsAndDrinksNamesEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: fields[2] as FoodsAndDrinkListsEntity,
    );
  }

  @override
  void write(BinaryWriter writer, FoodsAndDrinksNamesEntity obj) {
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
      other is FoodsAndDrinksNamesEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodsAndDrinkListsEntityAdapter
    extends TypeAdapter<FoodsAndDrinkListsEntity> {
  @override
  final int typeId = 19;

  @override
  FoodsAndDrinkListsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodsAndDrinkListsEntity(
      foodNames: (fields[0] as List).cast<FoodItemEntity>(),
      drinkNames: (fields[1] as List).cast<FoodItemEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodsAndDrinkListsEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.foodNames)
      ..writeByte(1)
      ..write(obj.drinkNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodsAndDrinkListsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodItemEntityAdapter extends TypeAdapter<FoodItemEntity> {
  @override
  final int typeId = 20;

  @override
  FoodItemEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItemEntity(
      id: fields[0] as int,
      en: fields[1] as String,
      es: fields[2] as String,
      g: fields[3] as String,
      units: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItemEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.en)
      ..writeByte(2)
      ..write(obj.es)
      ..writeByte(3)
      ..write(obj.g)
      ..writeByte(4)
      ..write(obj.units);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodsAndDrinksNamesEntity _$FoodsAndDrinksNamesEntityFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinksNamesEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: FoodsAndDrinkListsEntity.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesEntityToJson(
        FoodsAndDrinksNamesEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.toJson(),
    };

FoodsAndDrinkListsEntity _$FoodsAndDrinkListsEntityFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinkListsEntity(
      foodNames: (json['foodNames'] as List<dynamic>)
          .map((e) => FoodItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinkNames: (json['drinkNames'] as List<dynamic>)
          .map((e) => FoodItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FoodsAndDrinkListsEntityToJson(
        FoodsAndDrinkListsEntity instance) =>
    <String, dynamic>{
      'foodNames': instance.foodNames.map((e) => e.toJson()).toList(),
      'drinkNames': instance.drinkNames.map((e) => e.toJson()).toList(),
    };

FoodItemEntity _$FoodItemEntityFromJson(Map<String, dynamic> json) =>
    FoodItemEntity(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
      g: json['g'] as String,
      units: json['units'] as String?,
    );

Map<String, dynamic> _$FoodItemEntityToJson(FoodItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'g': instance.g,
      'units': instance.units,
    };
