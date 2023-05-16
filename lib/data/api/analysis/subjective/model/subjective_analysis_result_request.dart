import 'package:json_annotation/json_annotation.dart';

part 'subjective_analysis_result_request.g.dart';

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisResultRequest {
  String userId;
  int eventDate;
  List<SubjectiveAnalysisAnswerRequest> questionList;

  SubjectiveAnalysisResultRequest({
    required this.userId,
    required this.eventDate,
    required this.questionList,
  });

  factory SubjectiveAnalysisResultRequest.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisResultRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisResultRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisAnswerRequest {
  int questionId;
  int? value;
  List<SubjectiveAnalysisTestAnswerRequest>? testAnswerList;

  SubjectiveAnalysisAnswerRequest({
    required this.questionId,
    this.value,
    this.testAnswerList,
  });

  factory SubjectiveAnalysisAnswerRequest.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisAnswerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisAnswerRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisTestAnswerRequest {
  int testQuestionId;
  int answersType;

  SubjectiveAnalysisTestAnswerRequest({
    required this.testQuestionId,
    required this.answersType,
  });

  factory SubjectiveAnalysisTestAnswerRequest.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisTestAnswerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisTestAnswerRequestToJson(this);
}