// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisListMaster _$SubjectiveAnalysisListMasterFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisListMaster(
      subjectiveAnalysisList: (json['subjectiveAnalysisList'] as List<dynamic>)
          .map((e) =>
              SubjectiveAnalysisMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisListMasterToJson(
        SubjectiveAnalysisListMaster instance) =>
    <String, dynamic>{
      'subjectiveAnalysisList':
          instance.subjectiveAnalysisList.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisMaster _$SubjectiveAnalysisMasterFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisMaster(
      questionId: (json['questionId'] as num).toInt(),
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['questionType']),
      parameter_en: json['parameter_en'] as String?,
      parameter_es: json['parameter_es'] as String?,
      objectivesId: (json['objectivesId'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      subjectiveAnalysisTestMaster_en:
          json['subjectiveAnalysisTestMaster_en'] == null
              ? null
              : SubjectiveAnalysisTestMaster.fromJson(
                  json['subjectiveAnalysisTestMaster_en']
                      as Map<String, dynamic>),
      subjectiveAnalysisTestMaster_es:
          json['subjectiveAnalysisTestMaster_es'] == null
              ? null
              : SubjectiveAnalysisTestMaster.fromJson(
                  json['subjectiveAnalysisTestMaster_es']
                      as Map<String, dynamic>),
      evaluation: json['evaluation'] as String,
    );

Map<String, dynamic> _$SubjectiveAnalysisMasterToJson(
        SubjectiveAnalysisMaster instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'questionType': _$QuestionTypeEnumMap[instance.questionType]!,
      'parameter_en': instance.parameter_en,
      'parameter_es': instance.parameter_es,
      'objectivesId': instance.objectivesId,
      'subjectiveAnalysisTestMaster_en':
          instance.subjectiveAnalysisTestMaster_en?.toJson(),
      'subjectiveAnalysisTestMaster_es':
          instance.subjectiveAnalysisTestMaster_es?.toJson(),
      'evaluation': instance.evaluation,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.parameter: 'parameter',
  QuestionType.test: 'test',
};

SubjectiveAnalysisTestMaster _$SubjectiveAnalysisTestMasterFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisTestMaster(
      questions: (json['questions'] as List<dynamic>)
          .map((e) => TestQuestionMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisTestMasterToJson(
        SubjectiveAnalysisTestMaster instance) =>
    <String, dynamic>{
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

TestQuestionMaster _$TestQuestionMasterFromJson(Map<String, dynamic> json) =>
    TestQuestionMaster(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      afirm: json['afirm'] as String,
      neg: json['neg'] as String,
    );

Map<String, dynamic> _$TestQuestionMasterToJson(TestQuestionMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'afirm': instance.afirm,
      'neg': instance.neg,
    };
