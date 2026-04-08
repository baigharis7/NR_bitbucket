import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'foods_and_drinks_names_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodsAndDrinksNamesEntity)
class FoodsAndDrinksNamesEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) FoodsAndDrinkListsEntity data;

  FoodsAndDrinksNamesEntity({required this.id, required this.v, required this.data});

  factory FoodsAndDrinksNamesEntity.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodsAndDrinkListsEntity)
class FoodsAndDrinkListsEntity {
  @HiveField(0) List<FoodItemEntity> foodNames;
  @HiveField(1) List<FoodItemEntity> drinkNames;

  FoodsAndDrinkListsEntity({required this.foodNames, required this.drinkNames});

  factory FoodsAndDrinkListsEntity.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinkListsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinkListsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodItemEntity)
class FoodItemEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;
  @HiveField(3) String g;
  @HiveField(4) String? units;
  @HiveField(5) int included;

  FoodItemEntity({required this.id, required this.en, required this.es, required this.g, required this.units, this.included = 0});

  factory FoodItemEntity.fromJson(Map<String, dynamic> json) => _$FoodItemEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemEntityToJson(this);
}