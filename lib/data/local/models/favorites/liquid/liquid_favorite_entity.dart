import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'liquid_favorite_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.liquidFavoriteEntity)
class LiquidFavoriteEntity extends HiveObject {
  static const boxName = 'liquid_favorites';

  @HiveField(0) List<LiquidInFavoriteEntity> ingredients = [];
  @HiveField(1) List<LiquidInFavoriteEntity> drinks = [];
  @HiveField(2) String? comment;
  @HiveField(3) int mealTime;
  @HiveField(4) String title;
  @HiveField(5) int eventDate;


  LiquidFavoriteEntity({
    required this.ingredients,
    required this.drinks,
    this.comment,
    required this.mealTime,
    required this.title,
    required this.eventDate,
  });

  factory LiquidFavoriteEntity.fromJson(Map<String, dynamic> json) => _$LiquidFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidFavoriteEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.liquidInFavoriteEntity)
class LiquidInFavoriteEntity {
  @HiveField(0) int id;
  @HiveField(1) int qty;
  @HiveField(2) int unit;
  @HiveField(3) int cookingMethod;
  @HiveField(4) String? unitsEquivalences;
  @HiveField(5) String? name_en;
  @HiveField(6) String? name_es;

  LiquidInFavoriteEntity({
    required this.id,
    required this.qty,
    required this.unit,
    required this.cookingMethod,
    this.unitsEquivalences,
    required this.name_en,
    required this.name_es,
  });

  factory LiquidInFavoriteEntity.fromJson(Map<String, dynamic> json) => _$LiquidInFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidInFavoriteEntityToJson(this);
}