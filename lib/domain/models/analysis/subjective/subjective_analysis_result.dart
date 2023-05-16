import 'package:json_annotation/json_annotation.dart';

part 'subjective_analysis_result.g.dart';

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisResult {
  String userId;
  int eventDate;
  List<SubjectiveAnalysisAnswerResult> questionList;

  SubjectiveAnalysisResult({
    required this.userId,
    required this.eventDate,
    required this.questionList,
  });

  factory SubjectiveAnalysisResult.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisAnswerResult {
  int questionId;
  int? value;
  List<SubjectiveAnalysisTestAnswer>? testAnswerList;

  SubjectiveAnalysisAnswerResult({
    required this.questionId,
    this.value,
    this.testAnswerList,
  });

  factory SubjectiveAnalysisAnswerResult.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisAnswerResultFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisAnswerResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisTestAnswer {
  int testQuestionId;
  int answersType;

  SubjectiveAnalysisTestAnswer({
    required this.testQuestionId,
    required this.answersType,
  });

  factory SubjectiveAnalysisTestAnswer.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisTestAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisTestAnswerToJson(this);
}

enum AnswersType {
  positive, negative
}