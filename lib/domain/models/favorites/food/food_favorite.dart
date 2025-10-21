import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'food_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodFavorite {
  String? userId;
  int? eventId;
  int? eventDate;
  List<FoodInFavorite> ingredients = [];
  List<FoodInFavorite> drinks = [];
  String? title;
  String? comment;
  int? mealTime;
  bool? dish;
  bool? isRoutine;
  List<int>? daysOfWeek;
  String? time;
  String? timeZone;
  bool? isFavorite;

  FoodFavorite({
    this.userId,
    this.eventId,
    this.eventDate,
    required this.ingredients,
    required this.drinks,
    this.title,
    this.comment,
    required this.mealTime,
    this.dish,
    this.isRoutine,
    this.daysOfWeek,
    this.time,
    this.timeZone,
    this.isFavorite,
  });

  FoodFavorite.empty({int? eventData, int? mealTime})
      : ingredients = [],
        eventDate = eventData,
        daysOfWeek = [],
        mealTime = mealTime ?? 0,
        drinks = [];

  factory FoodFavorite.fromJson(Map<String, dynamic> json) => _$FoodFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FoodFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodInFavorite extends Translatable {
  int id;
  String? name_en;
  String? name_es;
  int qty;
  int unit;
  int? conversionFactor;
  int? usedOil;
  int cookingMethod;
  String? unitsEquivalences;

  FoodInFavorite({
    required this.id,
    this.name_en,
    this.name_es,
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