import 'package:json_annotation/json_annotation.dart';

part 'foods_and_drinks_names_response.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinksNamesResponse {
  int v;
  FoodsAndDrinkListsResponse data;

  FoodsAndDrinksNamesResponse({required this.v, required this.data});

  factory FoodsAndDrinksNamesResponse.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinksNamesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinksNamesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodsAndDrinkListsResponse {
  List<FoodItemResponse> foodNames;
  List<FoodItemResponse> drinkNames;

  FoodsAndDrinkListsResponse({required this.foodNames, required this.drinkNames});

  factory FoodsAndDrinkListsResponse.fromJson(Map<String, dynamic> json) => _$FoodsAndDrinkListsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FoodsAndDrinkListsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodItemResponse {
  int id;
  String en;
  String es;
  String g;

  FoodItemResponse({required this.id, required this.en, required this.es, required this.g});

  factory FoodItemResponse.fromJson(Map<String, dynamic> json) => _$FoodItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemResponseToJson(this);
}