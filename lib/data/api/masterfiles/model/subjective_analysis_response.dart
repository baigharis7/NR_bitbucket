// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'subjective_analysis_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisListResponse {
  final int v;
  final List<SubjectiveAnalysisResponse> data;

  SubjectiveAnalysisListResponse({
    required this.v,
    required this.data,
  });

  factory SubjectiveAnalysisListResponse.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisResponse {
  final int q_id;
  final int q_type;
  final String? q_es;
  final String? q_en;
  final List<int> obj_id;
  final List<TestQuestionAnswerResponse>? ans_en;
  final List<TestQuestionAnswerResponse>? ans_es;
  final String? eval;

  SubjectiveAnalysisResponse({
    required this.q_id,
    required this.q_type,
    required this.q_en,
    required this.q_es,
    required this.obj_id,
    required this.ans_en,
    required this.ans_es,
    required this.eval,
  });

  factory SubjectiveAnalysisResponse.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TestQuestionAnswerResponse {
  final int id;
  final String title;
  final String afirm;
  final String neg;

  TestQuestionAnswerResponse({
    required this.id,
    required this.title,
    required this.afirm,
    required this.neg,
  });

  factory TestQuestionAnswerResponse.fromJson(Map<String, dynamic> json) => _$TestQuestionAnswerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TestQuestionAnswerResponseToJson(this);
}