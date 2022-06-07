import 'package:json_annotation/json_annotation.dart';

part 'food_names_master.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinksNamesMaster {
  @JsonKey(name: 'foodsAndDrinksNames')
  FoodsAndDrinkListsMaster? foodsAndDrinksNames;

  FoodsAndDrinksNamesMaster(this.foodsAndDrinksNames);

  factory FoodsAndDrinksNamesMaster.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinkListsMaster{
  @JsonKey(name: 'foodNames')
  List<FoodItemMaster>? foodNames;
  @JsonKey(name: 'drinkNames')
  List<FoodItemMaster>? drinkNames;

  FoodsAndDrinkListsMaster({this.foodNames, this.drinkNames});
  FoodsAndDrinkListsMaster.createEmptyList() : this(foodNames: [], drinkNames: []);

  factory FoodsAndDrinkListsMaster.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinkListsMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinkListsMasterToJson(this);
}

@JsonSerializable()
class FoodItemMaster{
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'en')
  String? en;
  @JsonKey(name: 'es')
  String? es;
  @JsonKey(name: 'group')
  String? group;

  FoodItemMaster({this.id, this.en, this.es, this.group});

  factory FoodItemMaster.fromJson(Map<String, dynamic> json) => _$FoodItemMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemMasterToJson(this);
}