import 'package:json_annotation/json_annotation.dart';

part 'food_routine_event.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodRoutineEvent {
  String userId;
  int eventDate;
  int? eventId;
  int? mealType;
  String? foodName;
  String? comment;
  List<FoodRoutineInEvent>? ingredients;
  List<FoodRoutineInEvent>? drinks;
  bool? dish;
  bool? isRoutine;
  List<int>? daysOfWeek;
  String? time;

  FoodRoutineEvent({required this.userId, required this.eventDate, this.eventId, this.mealType, required this.foodName, required this.comment, this.ingredients, this.drinks, this.dish, this.isRoutine, this.daysOfWeek, this.time});

  factory FoodRoutineEvent.fromJson(Map<String, dynamic> json) => _$FoodRoutineEventFromJson(json);
  Map<String, dynamic> toJson() => _$FoodRoutineEventToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodRoutineInEvent {
  int id;
  int qty;
  int unit;
  int? conversionFactor;
  int cookingMethod;
  int? usedOil;
  String? unitsEquivalences;

  FoodRoutineInEvent({required this.id, required this.qty, required this.unit, this.conversionFactor, required this.cookingMethod, this.usedOil, this.unitsEquivalences});

  factory FoodRoutineInEvent.fromJson(Map<String, dynamic> json) => _$FoodRoutineInEventFromJson(json);
  Map<String, dynamic> toJson() => _$FoodRoutineInEventToJson(this);
}