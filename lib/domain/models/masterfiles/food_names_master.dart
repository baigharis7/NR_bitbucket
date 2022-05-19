import 'package:json_annotation/json_annotation.dart';

part 'food_names_master.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodAndDrinksNamesMaster {
  @JsonKey(name: 'foodAndDrinksNames')
  FoodAndDrinksNames? foodAndDrinksNames;

  FoodAndDrinksNamesMaster(this.foodAndDrinksNames);

  factory FoodAndDrinksNamesMaster.fromJson(Map<String, dynamic> json) => _$FoodAndDrinksNamesMasterFromJson(json);
  Map<String, dynamic> toJson() => _$FoodAndDrinksNamesMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodAndDrinksNames {
  @JsonKey(name: 'v')
  int? v;
  @JsonKey(name: 'data')
  FoodsAndDrinkListsMaster? data;

  FoodAndDrinksNames(this.v, this.data);

  factory FoodAndDrinksNames.fromJson(Map<String, dynamic> json) => _$FoodAndDrinksNamesFromJson(json);
  Map<String, dynamic> toJson() => _$FoodAndDrinksNamesToJson(this);
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

FoodAndDrinksNames foodAndDrinksNamesFromJson(Map<String, dynamic> json) =>
    FoodAndDrinksNames(
      json['v'],
      json['data'],
    );

Map<String, dynamic> foodAndDrinksNamesToJson(FoodAndDrinksNames instance) =>
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
