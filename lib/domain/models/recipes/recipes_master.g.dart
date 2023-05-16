// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeMaster _$RecipeMasterFromJson(Map<String, dynamic> json) => RecipeMaster(
      id: (json['id'] as num).toDouble(),
      meal: (json['meal'] as List<dynamic>).map((e) => e as int).toList(),
      name_es: json['name_es'] as String?,
      name_en: json['name_en'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps_es: json['steps_es'] == null
          ? null
          : RecipeSteps.fromJson(json['steps_es'] as Map<String, dynamic>),
      steps_en: json['steps_en'] == null
          ? null
          : RecipeSteps.fromJson(json['steps_en'] as Map<String, dynamic>),
      time: json['time'] as int?,
      difficulty: json['difficulty'] as int?,
      servings: json['servings'] as int?,
      source: json['source'] as String?,
      exclusions: json['exclusions'] as String?,
    );

Map<String, dynamic> _$RecipeMasterToJson(RecipeMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meal': instance.meal,
      'name_es': instance.name_es,
      'name_en': instance.name_en,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'steps_es': instance.steps_es?.toJson(),
      'steps_en': instance.steps_en?.toJson(),
      'time': instance.time,
      'difficulty': instance.difficulty,
      'servings': instance.servings,
      'source': instance.source,
      'exclusions': instance.exclusions,
    };

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    RecipeIngredient(
      id: json['id'] as int,
      qtyGrams: (json['qtyGrams'] as num).toDouble(),
      qtyUnit: (json['qtyUnit'] as num).toDouble(),
      unit: json['unit'] as int,
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qtyGrams': instance.qtyGrams,
      'qtyUnit': instance.qtyUnit,
      'unit': instance.unit,
    };

RecipeSteps _$RecipeStepsFromJson(Map<String, dynamic> json) => RecipeSteps(
      steps: (json['steps'] as List<dynamic>)
          .map((e) => Step.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeStepsToJson(RecipeSteps instance) =>
    <String, dynamic>{
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

Step _$StepFromJson(Map<String, dynamic> json) => Step(
      stepTitle: json['stepTitle'] as String?,
      subSteps:
          (json['subSteps'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
      'stepTitle': instance.stepTitle,
      'subSteps': instance.subSteps,
    };
