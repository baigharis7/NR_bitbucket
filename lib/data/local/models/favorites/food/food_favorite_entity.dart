import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'food_favorite_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodFavoriteEntity)
class FoodFavoriteEntity extends HiveObject  {
  static const boxName = 'food_favorites';

  @HiveField(0) List<FoodInFavoriteEntity> ingredients = [];
  @HiveField(1) List<FoodInFavoriteEntity> drinks = [];
  @HiveField(2) String? comment;
  @HiveField(3) int mealTime;
  @HiveField(4) String title;
  @HiveField(5) int eventDate;
  @HiveField(5) bool? dish;


  FoodFavoriteEntity({
    required this.ingredients,
    required this.drinks,
    this.comment,
    required this.mealTime,
    required this.title,
    required this.eventDate,
    this.dish,
  });

  factory FoodFavoriteEntity.fromJson(Map<String, dynamic> json) => _$FoodFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodFavoriteEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodInFavoriteEntity)
class FoodInFavoriteEntity {
  @HiveField(0) int id;
  @HiveField(1) int qty;
  @HiveField(2) int unit;
  @HiveField(3) int cookingMethod;
  @HiveField(4) String? unitsEquivalences;
  @HiveField(5) String? name_en;
  @HiveField(6) String? name_es;
  @HiveField(7) int? conversionFactor;
  @HiveField(8) int? usedOil;

  FoodInFavoriteEntity({
    required this.id,
    required this.qty,
    required this.unit,
    required this.cookingMethod,
    this.unitsEquivalences,
    required this.name_en,
    required this.name_es,
    this.conversionFactor,
    this.usedOil,
  });

  factory FoodInFavoriteEntity.fromJson(Map<String, dynamic> json) => _$FoodInFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodInFavoriteEntityToJson(this);
}