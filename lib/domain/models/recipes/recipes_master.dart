import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'recipes_master.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeMaster extends Translatable {
  double id;
  List<int> meal;
  String? name_es;
  String? name_en;
  List<RecipeIngredient> ingredients;
  RecipeSteps? steps_es;
  RecipeSteps? steps_en;
  int? time;
  int? difficulty;
  int? servings;
  String? source;
  String? exclusions;

  RecipeMaster({
    required this.id,
    required this.meal,
    required this.name_es,
    required this.name_en,
    required this.ingredients,
    required this.steps_es,
    required this.steps_en,
    required this.time,
    required this.difficulty,
    required this.servings,
    required this.source,
    required this.exclusions,
  });

  factory RecipeMaster.fromJson(Map<String, dynamic> json) => _$RecipeMasterFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeIngredient {
  int id;
  double qtyGrams;
  double qtyUnit;
  int unit;

  RecipeIngredient({
    required this.id,
    required this.qtyGrams,
    required this.qtyUnit,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeSteps {
  List<Step> steps;

  RecipeSteps({
    required this.steps,
  });

  factory RecipeSteps.fromJson(Map<String, dynamic> json) => _$RecipeStepsFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Step {
  String? stepTitle;
  List<String> subSteps;

  Step({
    this.stepTitle,
    required this.subSteps,
  });

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
  Map<String, dynamic> toJson() => _$StepToJson(this);
}