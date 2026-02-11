// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisResult _$SubjectiveAnalysisResultFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisResult(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      questionList: (json['questionList'] as List<dynamic>)
          .map((e) => SubjectiveAnalysisAnswerResult.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisResultToJson(
        SubjectiveAnalysisResult instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'questionList': instance.questionList.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisAnswerResult _$SubjectiveAnalysisAnswerResultFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisAnswerResult(
      questionId: (json['questionId'] as num).toInt(),
      value: (json['value'] as num?)?.toInt(),
      testAnswerList: (json['testAnswerList'] as List<dynamic>?)
          ?.map((e) =>
              SubjectiveAnalysisTestAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisAnswerResultToJson(
        SubjectiveAnalysisAnswerResult instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'value': instance.value,
      'testAnswerList':
          instance.testAnswerList?.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisTestAnswer _$SubjectiveAnalysisTestAnswerFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisTestAnswer(
      testQuestionId: (json['testQuestionId'] as num).toInt(),
      answersType: (json['answersType'] as num).toInt(),
    );

Map<String, dynamic> _$SubjectiveAnalysisTestAnswerToJson(
        SubjectiveAnalysisTestAnswer instance) =>
    <String, dynamic>{
      'testQuestionId': instance.testQuestionId,
      'answersType': instance.answersType,
    };
