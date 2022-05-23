import 'package:json_annotation/json_annotation.dart';

part 'foods_and_drinks_names_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinksNamesEntity {
  int id;
  int v;
  FoodsAndDrinkListsEntity data;

  FoodsAndDrinksNamesEntity({required this.id, required this.v, required this.data});

  factory FoodsAndDrinksNamesEntity.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinkListsEntity {
  List<FoodItemEntity> foodNames;
  List<FoodItemEntity> drinkNames;

  FoodsAndDrinkListsEntity({required this.foodNames, required this.drinkNames});

  factory FoodsAndDrinkListsEntity.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinkListsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinkListsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodItemEntity {
  int id;
  String en;
  String es;
  String g;

  FoodItemEntity({required this.id, required this.en, required this.es, required this.g});

  factory FoodItemEntity.fromJson(Map<String, dynamic> json) => _$FoodItemEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemEntityToJson(this);
}