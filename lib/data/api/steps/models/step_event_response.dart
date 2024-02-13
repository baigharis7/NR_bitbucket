import 'package:json_annotation/json_annotation.dart';
part 'step_event_response.g.dart';
@JsonSerializable(explicitToJson: true)
class StepEventResponse {
  int? eventId;
  int? initialSteps;
  int? actualSteps;

  StepEventResponse({required this.eventId, required this.initialSteps, required this.actualSteps});

  factory StepEventResponse.fromJson(Map<String, dynamic> json) => _$StepEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventResponseToJson(this);
}