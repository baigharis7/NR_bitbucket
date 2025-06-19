import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'food_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodFavorite {
  String title;
  int eventDate;
  List<FoodInFavorite> ingredients = [];
  List<FoodInFavorite> drinks = [];
  String? comment;
  int mealTime;
  bool? dish;
  bool? isRoutine;
  List<int>? daysOfWeek;
  String? time;
  String? timeZone;
  FoodFavorite({
    required this.title,
    required this.eventDate,
    required this.ingredients,
    required this.drinks,
    this.comment,
    required this.mealTime,
    this.dish,
    this.isRoutine,
    this.daysOfWeek,
    this.time,
    this.timeZone,
  });

  factory FoodFavorite.fromJson(Map<String, dynamic> json) => _$FoodFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FoodFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodInFavorite extends Translatable {
  int id;
  String name_en;
  String name_es;
  int qty;
  int unit;
  int? conversionFactor;
  int? usedOil;
  int cookingMethod;
  String? unitsEquivalences;

  FoodInFavorite({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.qty,
    required this.unit,
    this.conversionFactor,
    this.usedOil,
    required this.cookingMethod,
    this.unitsEquivalences,
  });

  factory FoodInFavorite.fromJson(Map<String, dynamic> json) => _$FoodInFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FoodInFavoriteToJson(this);
}