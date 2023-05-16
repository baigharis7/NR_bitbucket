// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

part 'subjective_analysis_master.g.dart';

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisListMaster {
  final List<SubjectiveAnalysisMaster> subjectiveAnalysisList;

  SubjectiveAnalysisListMaster({
    required this.subjectiveAnalysisList,
  });

  factory SubjectiveAnalysisListMaster.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisListMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisListMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisMaster {
  final int questionId;
  final QuestionType questionType;
  final String? parameter_en;
  final String? parameter_es;
  final List<int> objectivesId;
  final SubjectiveAnalysisTestMaster? subjectiveAnalysisTestMaster_en;
  final SubjectiveAnalysisTestMaster? subjectiveAnalysisTestMaster_es;
  final String evaluation; // Aquí habrá que hacer otra clase para albergar la información. Por determinar.

  SubjectiveAnalysisMaster({
    required this.questionId,
    required this.questionType,               
    required this.parameter_en,            
    required this.parameter_es,            
    required this.objectivesId,         
    required this.subjectiveAnalysisTestMaster_en,
    required this.subjectiveAnalysisTestMaster_es,
    required this.evaluation,
  });
  
  factory SubjectiveAnalysisMaster.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubjectiveAnalysisTestMaster {
  final List<TestQuestionMaster> questions;

  SubjectiveAnalysisTestMaster({
    required this.questions,
  });
  factory SubjectiveAnalysisTestMaster.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisTestMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisTestMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TestQuestionMaster {
  final int id;
  final String title;
  final String afirm;
  final String neg;

  TestQuestionMaster({
    required this.id,
    required this.title,
    required this.afirm,
    required this.neg,
  });

  factory TestQuestionMaster.fromJson(Map<String, dynamic> json) => _$TestQuestionMasterFromJson(json);
  Map<String, dynamic> toJson() => _$TestQuestionMasterToJson(this);
}

enum QuestionType {
  parameter, test,
}