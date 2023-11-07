import 'package:json_annotation/json_annotation.dart';

part 'food_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodEventSimple {
  String userId;
  int eventDate;
  int? eventId;
  String? foodName;
  String? comment;
  List<FoodInEvent>? ingredients;
  List<FoodInEvent>? drinks;

  FoodEventSimple({required this.userId, required this.eventDate, this.eventId, required this.foodName, required this.comment, this.ingredients, this.drinks});

  factory FoodEventSimple.fromJson(Map<String, dynamic> json) => _$FoodEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$FoodEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodInEvent {
  int id;
  int qty;
  int unit;
  bool errorFood;
  int cookingMethod;
  String? unitsEquivalences;

  FoodInEvent({required this.id, required this.qty, required this.unit, this.errorFood = false, required this.cookingMethod, this.unitsEquivalences});

  factory FoodInEvent.fromJson(Map<String, dynamic> json) => _$FoodInEventFromJson(json);
  Map<String, dynamic> toJson() => _$FoodInEventToJson(this);
}