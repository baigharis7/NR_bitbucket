import 'package:json_annotation/json_annotation.dart';

part 'upload_liquid_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadLiquidFavorite {
  String userId;
  int eventDate;
  String title;
  List<UploadLiquidInFavorite> ingredients = [];
  List<UploadLiquidInFavorite> drinks = [];
  String? comment;
  int mealTime;

  UploadLiquidFavorite({
    required this.userId,
    required this.eventDate,
    required this.title,
    required this.ingredients,
    required this.drinks,
    this.comment,
    required this.mealTime,
  });

  factory UploadLiquidFavorite.fromJson(Map<String, dynamic> json) => _$UploadLiquidFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadLiquidFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UploadLiquidInFavorite {
  int id;
  String? name_en;
  String? name_es;
  int qty;
  int unit;
  int cookingMethod;
  String? unitsEquivalences;

  UploadLiquidInFavorite({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.qty,
    required this.unit,
    required this.cookingMethod,
    this.unitsEquivalences,
  });

  factory UploadLiquidInFavorite.fromJson(Map<String, dynamic> json) => _$UploadLiquidInFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadLiquidInFavoriteToJson(this);
}