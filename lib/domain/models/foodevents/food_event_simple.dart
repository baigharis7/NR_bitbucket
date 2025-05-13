import 'package:json_annotation/json_annotation.dart';

part 'food_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodEventSimple {
  String userId;
  int eventDate;
  int? eventId;
  int? mealType;
  String? foodName;
  String? comment;
  List<FoodInEvent>? ingredients;
  List<FoodInEvent>? drinks;
  bool? dish;

  FoodEventSimple({required this.userId, required this.eventDate, this.eventId, this.mealType, required this.foodName, required this.comment, this.ingredients, this.drinks, this.dish});

  factory FoodEventSimple.fromJson(Map<String, dynamic> json) => _$FoodEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$FoodEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodInEvent {
  int id;
  int qty;
  int unit;
  int? conversionFactor;
  int cookingMethod;
  int? usedOil;
  String? unitsEquivalences;

  FoodInEvent({required this.id, required this.qty, required this.unit, this.conversionFactor, required this.cookingMethod, this.usedOil, this.unitsEquivalences});

  factory FoodInEvent.fromJson(Map<String, dynamic> json) => _$FoodInEventFromJson(json);
  Map<String, dynamic> toJson() => _$FoodInEventToJson(this);
}