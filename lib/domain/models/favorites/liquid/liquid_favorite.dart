import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'liquid_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class LiquidFavorite {
  String title;
  int eventDate;
  List<LiquidInFavorite> ingredients = [];
  List<LiquidInFavorite> drinks = [];
  String? comment;
  int mealTime;
  
  LiquidFavorite({
    required this.title,
    required this.eventDate,
    required this.ingredients,
    required this.drinks,
    this.comment,
    required this.mealTime,
  });

  factory LiquidFavorite.fromJson(Map<String, dynamic> json) => _$LiquidFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LiquidInFavorite extends Translatable {
  int id;
  String name_en;
  String name_es;
  int qty;
  int unit;
  int cookingMethod;
  String? unitsEquivalences;

  LiquidInFavorite({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.qty,
    required this.unit,
    required this.cookingMethod,
    this.unitsEquivalences,
  });

  factory LiquidInFavorite.fromJson(Map<String, dynamic> json) => _$LiquidInFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidInFavoriteToJson(this);
}