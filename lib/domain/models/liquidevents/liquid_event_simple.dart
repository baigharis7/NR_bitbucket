import 'package:json_annotation/json_annotation.dart';

part 'liquid_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class LiquidEventSimple {
  String userId;
  int date;
  List<LiquidInEvent>? drinks = [];

  LiquidEventSimple({required this.userId, required this.date, this.drinks});

  factory LiquidEventSimple.fromJson(Map<String, dynamic> json) => _$LiquidEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LiquidInEvent {
  int id;
  int qty;

  LiquidInEvent({required this.id, required this.qty});

  factory LiquidInEvent.fromJson(Map<String, dynamic> json) => _$LiquidInEventFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidInEventToJson(this);
}