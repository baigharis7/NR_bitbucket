import 'package:json_annotation/json_annotation.dart';

part 'recipes_response.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipesListResponse {
  List<RecipeResponse>? recipes;

  RecipesListResponse({
    required this.recipes,
  });

  factory RecipesListResponse.fromJson(Map<String, dynamic> json) => _$RecipesListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecipesListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeResponse {
  double id;
  String meal;
  String? name_es;
  String? name_en;
  String ingredients;
  String? steps_es;
  String? steps_en;
  int? time;
  int? difficulty;
  int? servings;
  String? source;
  String? exclusions;

  RecipeResponse({
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

  factory RecipeResponse.fromJson(Map<String, dynamic> json) => _$RecipeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeResponseToJson(this);
}