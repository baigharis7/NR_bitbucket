import 'package:json_annotation/json_annotation.dart';

part 'water_event_response.g.dart';

@JsonSerializable(explicitToJson: true)
class WaterEventResponse {
  bool uploadSuccess;

  WaterEventResponse({required this.uploadSuccess});

  factory WaterEventResponse.fromJson(Map<String, dynamic> json) => _$WaterEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WaterEventResponseToJson(this);
}