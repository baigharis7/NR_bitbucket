part 'upload_step_event_response.g.dart';

class UploadStepEventResponse {
  String? userId;
  int? eventId;
  int? initialSteps;
  int? actualSteps;

  UploadStepEventResponse({
    required this.userId,
    required this.eventId,
    required this.initialSteps,
    required this.actualSteps,
  });

  factory UploadStepEventResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadStepEventResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadStepEventResponseToJson(this);
}
