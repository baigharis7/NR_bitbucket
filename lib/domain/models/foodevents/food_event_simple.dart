import 'package:json_annotation/json_annotation.dart';

part 'food_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class FoodEventSimple {
  String userId;
  int date;
  List<FoodInEvent> ingredients = [];
  List<FoodInEvent> drinks = [];

  FoodEventSimple({required this.userId, required this.date});

  factory FoodEventSimple.fromJson(Map<String, dynamic> json) => _$FoodEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$FoodEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FoodInEvent {
  int id;
  int qty;
  int unit;
  int cookingMethod;

  FoodInEvent({required this.id, required this.qty, required this.unit, required this.cookingMethod});

  factory FoodInEvent.fromJson(Map<String, dynamic> json) => _$FoodInEventFromJson(json);
  Map<String, dynamic> toJson() => _$FoodInEventToJson(this);
}