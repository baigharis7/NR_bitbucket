// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_result_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisResultRequest _$SubjectiveAnalysisResultRequestFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisResultRequest(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      questionList: (json['questionList'] as List<dynamic>)
          .map((e) => SubjectiveAnalysisAnswerRequest.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisResultRequestToJson(
        SubjectiveAnalysisResultRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'questionList': instance.questionList.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisAnswerRequest _$SubjectiveAnalysisAnswerRequestFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisAnswerRequest(
      questionId: (json['questionId'] as num).toInt(),
      value: (json['value'] as num?)?.toInt(),
      testAnswerList: (json['testAnswerList'] as List<dynamic>?)
          ?.map((e) => SubjectiveAnalysisTestAnswerRequest.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisAnswerRequestToJson(
        SubjectiveAnalysisAnswerRequest instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'value': instance.value,
      'testAnswerList':
          instance.testAnswerList?.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisTestAnswerRequest
    _$SubjectiveAnalysisTestAnswerRequestFromJson(Map<String, dynamic> json) =>
        SubjectiveAnalysisTestAnswerRequest(
          testQuestionId: (json['testQuestionId'] as num).toInt(),
          answersType: (json['answersType'] as num).toInt(),
        );

Map<String, dynamic> _$SubjectiveAnalysisTestAnswerRequestToJson(
        SubjectiveAnalysisTestAnswerRequest instance) =>
    <String, dynamic>{
      'testQuestionId': instance.testQuestionId,
      'answersType': instance.answersType,
    };
