import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'food_routine_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodRoutineEntity)
class FoodRoutineEntity extends HiveObject {
  static const boxName = 'food_routines';

  @HiveField(0) String userId;
  @HiveField(1) int eventDate;
  @HiveField(2) int? eventId;
  @HiveField(3) int? mealType;
  @HiveField(4) String? foodName;
  @HiveField(5) String? comment;
  @HiveField(6) List<FoodRoutineInEntity>? ingredients;
  @HiveField(7) List<FoodRoutineInEntity>? drinks;
  @HiveField(8) bool? dish;
  @HiveField(9) bool? isRoutine;
  @HiveField(10) List<int>? daysOfWeek;
  @HiveField(11) String? timeZone;

  FoodRoutineEntity({required this.userId, required this.eventDate, this.eventId, this.mealType, required this.foodName, required this.comment, this.ingredients, this.drinks, this.dish, this.isRoutine, this.daysOfWeek, this.timeZone});

  factory FoodRoutineEntity.fromJson(Map<String, dynamic> json) => _$FoodRoutineEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodRoutineEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodRoutineInEntity)
class FoodRoutineInEntity {
  @HiveField(0) int id;
  @HiveField(1) int qty;
  @HiveField(2) int unit;
  @HiveField(3) int? conversionFactor;
  @HiveField(4) int cookingMethod;
  @HiveField(5) int? usedOil;
  @HiveField(6) String? unitsEquivalences;

  FoodRoutineInEntity({required this.id, required this.qty, required this.unit, this.conversionFactor, required this.cookingMethod, this.usedOil, this.unitsEquivalences});

  factory FoodRoutineInEntity.fromJson(Map<String, dynamic> json) => _$FoodRoutineInEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodRoutineInEntityToJson(this);
}