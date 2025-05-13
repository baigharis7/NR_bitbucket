import 'package:json_annotation/json_annotation.dart';

part 'upload_food_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadFoodFavorite {
  String userId;
  int eventDate;
  String title;
  List<UploadFoodInFavorite> ingredients = [];
  List<UploadFoodInFavorite> drinks = [];
  String? comment;
  int mealTime;
  bool? dish;

  UploadFoodFavorite({
    required this.userId,
    required this.eventDate,
    required this.title,
    required this.ingredients,
    required this.drinks,
    this.comment,
    this.dish,
    required this.mealTime,
  });

  factory UploadFoodFavorite.fromJson(Map<String, dynamic> json) => _$UploadFoodFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFoodFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UploadFoodInFavorite {
  int id;
  String? name_en;
  String? name_es;
  int qty;
  int unit;
  int? conversionFactor;
  int? usedOil;
  int cookingMethod;
  String? unitsEquivalences;

  UploadFoodInFavorite({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.qty,
    required this.unit,
    required this.cookingMethod,
    this.conversionFactor,
    this.usedOil,
    this.unitsEquivalences,
  });

  factory UploadFoodInFavorite.fromJson(Map<String, dynamic> json) => _$UploadFoodInFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFoodInFavoriteToJson(this);
}