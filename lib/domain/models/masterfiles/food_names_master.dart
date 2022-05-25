import 'package:json_annotation/json_annotation.dart';

part 'food_names_master.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinksNamesMaster {
  @JsonKey(name: 'foodsAndDrinksNames')
  FoodsAndDrinksNames? foodsAndDrinksNames;

  FoodsAndDrinksNamesMaster(this.foodsAndDrinksNames);

  factory FoodsAndDrinksNamesMaster.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinksNames {
  @JsonKey(name: 'v')
  int? v;
  @JsonKey(name: 'data')
  FoodsAndDrinkListsMaster? data;

  FoodsAndDrinksNames(this.v, this.data);

  factory FoodsAndDrinksNames.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinkListsMaster{
  @JsonKey(name: 'foodNames')
  List<FoodItemMaster>? foodNames;
  @JsonKey(name: 'drinkNames')
  List<FoodItemMaster>? drinkNames;

  FoodsAndDrinkListsMaster(this.foodNames, this.drinkNames);
  FoodsAndDrinkListsMaster.createEmptyList() : this([], []);

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

  FoodItemMaster(this.id, this.en, this.es, this.group);

  factory FoodItemMaster.fromJson(Map<String, dynamic> json) => _$FoodItemMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemMasterToJson(this);
}

FoodsAndDrinksNames foodsAndDrinksNamesFromJson(Map<String, dynamic> json) =>
    FoodsAndDrinksNames(
      json['v'],
      json['data'],
    );

Map<String, dynamic> foodsAndDrinksNamesToJson(FoodsAndDrinksNames instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data?.toJson(),
    };

FoodsAndDrinkListsMaster foodsAndDrinkListsMasterFromJson(
    Map<String, dynamic> json) =>
    FoodsAndDrinkListsMaster(
      json['foodNames'],
      json['drinkNames'],
    );

Map<String, dynamic> foodsAndDrinkListsMasterToJson(
    FoodsAndDrinkListsMaster instance) =>
    <String, dynamic>{
      'foodNames': instance.foodNames?.map((e) => e.toJson()).toList(),
      'drinkNames': instance.drinkNames?.map((e) => e.toJson()).toList(),
    };

FoodItemMaster foodItemMasterFromJson(Map<String, dynamic> json) =>
    FoodItemMaster(
      json['id'],
      json['en'],
      json['es'],
      json['group'],
    );

Map<String, dynamic> foodItemMasterToJson(FoodItemMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'group': instance.group,
    };
