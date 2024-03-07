// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_favorite_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeFavoriteEntityAdapter extends TypeAdapter<RecipeFavoriteEntity> {
  @override
  final int typeId = 59;

  @override
  RecipeFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeFavoriteEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      itemRecipe: fields[2] as RecipeMasterEntity,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeFavoriteEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.itemRecipe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeMasterEntityAdapter extends TypeAdapter<RecipeMasterEntity> {
  @override
  final int typeId = 60;

  @override
  RecipeMasterEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeMasterEntity(
      id: fields[0] as double,
      meal: (fields[1] as List).cast<int>(),
      name_es: fields[2] as String?,
      name_en: fields[3] as String?,
      ingredients: (fields[4] as List).cast<RecipeIngredientEntity>(),
      steps_es: fields[5] as RecipeStepsEntity?,
      steps_en: fields[6] as RecipeStepsEntity?,
      time: fields[7] as int?,
      difficulty: fields[8] as int?,
      servings: fields[9] as int?,
      source: fields[10] as String?,
      exclusions: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeMasterEntity obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.meal)
      ..writeByte(2)
      ..write(obj.name_es)
      ..writeByte(3)
      ..write(obj.name_en)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.steps_es)
      ..writeByte(6)
      ..write(obj.steps_en)
      ..writeByte(7)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.servings)
      ..writeByte(10)
      ..write(obj.source)
      ..writeByte(11)
      ..write(obj.exclusions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeMasterEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeIngredientEntityAdapter
    extends TypeAdapter<RecipeIngredientEntity> {
  @override
  final int typeId = 61;

  @override
  RecipeIngredientEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeIngredientEntity(
      id: fields[0] as int,
      qtyGrams: fields[1] as double,
      qtyUnit: fields[2] as double,
      unit: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeIngredientEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.qtyGrams)
      ..writeByte(2)
      ..write(obj.qtyUnit)
      ..writeByte(3)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredientEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeStepsEntityAdapter extends TypeAdapter<RecipeStepsEntity> {
  @override
  final int typeId = 62;

  @override
  RecipeStepsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStepsEntity(
      steps: (fields[0] as List).cast<RecipeStepEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStepsEntity obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeStepEntityAdapter extends TypeAdapter<RecipeStepEntity> {
  @override
  final int typeId = 63;

  @override
  RecipeStepEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStepEntity(
      stepTitle: fields[0] as String?,
      subSteps: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStepEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.stepTitle)
      ..writeByte(1)
      ..write(obj.subSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeFavoriteEntity _$RecipeFavoriteEntityFromJson(
        Map<String, dynamic> json) =>
    RecipeFavoriteEntity(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      itemRecipe: RecipeMasterEntity.fromJson(
          json['itemRecipe'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeFavoriteEntityToJson(
        RecipeFavoriteEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'itemRecipe': instance.itemRecipe.toJson(),
    };

RecipeMasterEntity _$RecipeMasterEntityFromJson(Map<String, dynamic> json) =>
    RecipeMasterEntity(
      id: (json['id'] as num).toDouble(),
      meal: (json['meal'] as List<dynamic>).map((e) => e as int).toList(),
      name_es: json['name_es'] as String?,
      name_en: json['name_en'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
              (e) => RecipeIngredientEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps_es: json['steps_es'] == null
          ? null
          : RecipeStepsEntity.fromJson(
              json['steps_es'] as Map<String, dynamic>),
      steps_en: json['steps_en'] == null
          ? null
          : RecipeStepsEntity.fromJson(
              json['steps_en'] as Map<String, dynamic>),
      time: json['time'] as int?,
      difficulty: json['difficulty'] as int?,
      servings: json['servings'] as int?,
      source: json['source'] as String?,
      exclusions: json['exclusions'] as String?,
    );

Map<String, dynamic> _$RecipeMasterEntityToJson(RecipeMasterEntity instance) =>
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

RecipeIngredientEntity _$RecipeIngredientEntityFromJson(
        Map<String, dynamic> json) =>
    RecipeIngredientEntity(
      id: json['id'] as int,
      qtyGrams: (json['qtyGrams'] as num).toDouble(),
      qtyUnit: (json['qtyUnit'] as num).toDouble(),
      unit: json['unit'] as int,
    );

Map<String, dynamic> _$RecipeIngredientEntityToJson(
        RecipeIngredientEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qtyGrams': instance.qtyGrams,
      'qtyUnit': instance.qtyUnit,
      'unit': instance.unit,
    };

RecipeStepsEntity _$RecipeStepsEntityFromJson(Map<String, dynamic> json) =>
    RecipeStepsEntity(
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStepEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeStepsEntityToJson(RecipeStepsEntity instance) =>
    <String, dynamic>{
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };

RecipeStepEntity _$RecipeStepEntityFromJson(Map<String, dynamic> json) =>
    RecipeStepEntity(
      stepTitle: json['stepTitle'] as String?,
      subSteps:
          (json['subSteps'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RecipeStepEntityToJson(RecipeStepEntity instance) =>
    <String, dynamic>{
      'stepTitle': instance.stepTitle,
      'subSteps': instance.subSteps,
    };
