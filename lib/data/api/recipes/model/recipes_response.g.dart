// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipesListResponse _$RecipesListResponseFromJson(Map<String, dynamic> json) =>
    RecipesListResponse(
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((e) => RecipeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipesListResponseToJson(
        RecipesListResponse instance) =>
    <String, dynamic>{
      'recipes': instance.recipes?.map((e) => e.toJson()).toList(),
    };

RecipeResponse _$RecipeResponseFromJson(Map<String, dynamic> json) =>
    RecipeResponse(
      id: (json['id'] as num).toDouble(),
      meal: json['meal'] as String,
      name_es: json['name_es'] as String?,
      name_en: json['name_en'] as String?,
      ingredients: json['ingredients'] as String,
      steps_es: json['steps_es'] as String?,
      steps_en: json['steps_en'] as String?,
      time: (json['time'] as num?)?.toInt(),
      difficulty: (json['difficulty'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      source: json['source'] as String?,
      exclusions: json['exclusions'] as String?,
    );

Map<String, dynamic> _$RecipeResponseToJson(RecipeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meal': instance.meal,
      'name_es': instance.name_es,
      'name_en': instance.name_en,
      'ingredients': instance.ingredients,
      'steps_es': instance.steps_es,
      'steps_en': instance.steps_en,
      'time': instance.time,
      'difficulty': instance.difficulty,
      'servings': instance.servings,
      'source': instance.source,
      'exclusions': instance.exclusions,
    };
