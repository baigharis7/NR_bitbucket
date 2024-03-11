import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'recipe_favorite_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recipeFavoriteEntity)
class RecipeFavoriteEntity extends HiveObject {
  static const boxName = 'recipe_favorite';

  @HiveField(0) String? userId;
  @HiveField(1) int? eventDate;
  @HiveField(2) RecipeMasterEntity itemRecipe;

  RecipeFavoriteEntity({required this.userId, required this.eventDate, required this.itemRecipe});
  
  factory RecipeFavoriteEntity.fromJson(Map<String, dynamic> json) => _$RecipeFavoriteEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeFavoriteEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recipeFavoriteMasterEntity)
class RecipeMasterEntity {
  @HiveField(0) double id;
  @HiveField(1) List<int> meal;
  @HiveField(2) String? name_es;
  @HiveField(3) String? name_en;
  @HiveField(4) List<RecipeIngredientEntity> ingredients;
  @HiveField(5) RecipeStepsEntity? steps_es;
  @HiveField(6) RecipeStepsEntity? steps_en;
  @HiveField(7) int? time;
  @HiveField(8) int? difficulty;
  @HiveField(9) int? servings;
  @HiveField(10) String? source;
  @HiveField(11) String? exclusions;

  RecipeMasterEntity({
    required this.id,
    required this.meal,
    this.name_es,
    this.name_en,
    required this.ingredients,
    this.steps_es,
    this.steps_en,
    this.time,
    this.difficulty,
    this.servings,
    this.source,
    this.exclusions,
  });
  
  factory RecipeMasterEntity.fromJson(Map<String, dynamic> json) => _$RecipeMasterEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeMasterEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recipeFavoriteIngredientEntity)
class RecipeIngredientEntity {
  @HiveField(0) int id;
  @HiveField(1) double qtyGrams;
  @HiveField(2) double qtyUnit;
  @HiveField(3) int unit;

  RecipeIngredientEntity({
    required this.id,
    required this.qtyGrams,
    required this.qtyUnit,
    required this.unit,
  });
  
  factory RecipeIngredientEntity.fromJson(Map<String, dynamic> json) => _$RecipeIngredientEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recipeFavoriteStepsEntity)
class RecipeStepsEntity {
  @HiveField(0) List<RecipeStepEntity> steps;

  RecipeStepsEntity({
    required this.steps,
  });
  
  factory RecipeStepsEntity.fromJson(Map<String, dynamic> json) => _$RecipeStepsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recipeFavoriteStepEntity)
class RecipeStepEntity {
  @HiveField(0) String? stepTitle;
  @HiveField(1) List<String> subSteps;

  RecipeStepEntity({
    this.stepTitle,
    required this.subSteps,
  });
  
  factory RecipeStepEntity.fromJson(Map<String, dynamic> json) => _$RecipeStepEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepEntityToJson(this);
}