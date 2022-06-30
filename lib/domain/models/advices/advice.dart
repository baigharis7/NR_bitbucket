import 'package:json_annotation/json_annotation.dart';

part 'advice.g.dart';

@JsonSerializable(explicitToJson: true)
class Advice {
  int id;
  String advEs;
  String? advEn;
  List<int> objective;
  int interaction;

  Advice({required this.id, required this.advEs, this.advEn, required this.objective, required this.interaction, });

  factory Advice.fromJson(Map<String, dynamic> json) => _$AdviceFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceToJson(this);
}