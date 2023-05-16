import 'package:json_annotation/json_annotation.dart';

part 'upload_subjective_analysis_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadSubjectiveAnalysisResponse {
  final bool uploadSuccess;

  UploadSubjectiveAnalysisResponse({required this.uploadSuccess});

  factory UploadSubjectiveAnalysisResponse.fromJson(Map<String, dynamic> json) => _$UploadSubjectiveAnalysisResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSubjectiveAnalysisResponseToJson(this);
}