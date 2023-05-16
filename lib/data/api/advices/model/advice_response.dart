import 'package:json_annotation/json_annotation.dart';

part 'advice_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AdviceResponse {
  int id;
  String adv_es;
  String? adv_en;
  List<int> objective;
  int interaction;

  AdviceResponse({required this.id, required this.adv_es, required this.adv_en, required this.objective, required this.interaction, });

  factory AdviceResponse.fromJson(Map<String, dynamic> json) => _$AdviceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceResponseToJson(this);
}