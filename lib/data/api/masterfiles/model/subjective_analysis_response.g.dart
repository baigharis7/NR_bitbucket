// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisListResponse _$SubjectiveAnalysisListResponseFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisListResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              SubjectiveAnalysisResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisListResponseToJson(
        SubjectiveAnalysisListResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisResponse _$SubjectiveAnalysisResponseFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisResponse(
      q_id: json['q_id'] as int,
      q_type: json['q_type'] as int,
      q_en: json['q_en'] as String?,
      q_es: json['q_es'] as String?,
      obj_id: (json['obj_id'] as List<dynamic>).map((e) => e as int).toList(),
      ans_en: (json['ans_en'] as List<dynamic>?)
          ?.map((e) =>
              TestQuestionAnswerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      ans_es: (json['ans_es'] as List<dynamic>?)
          ?.map((e) =>
              TestQuestionAnswerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      eval: json['eval'] as String?,
    );

Map<String, dynamic> _$SubjectiveAnalysisResponseToJson(
        SubjectiveAnalysisResponse instance) =>
    <String, dynamic>{
      'q_id': instance.q_id,
      'q_type': instance.q_type,
      'q_es': instance.q_es,
      'q_en': instance.q_en,
      'obj_id': instance.obj_id,
      'ans_en': instance.ans_en?.map((e) => e.toJson()).toList(),
      'ans_es': instance.ans_es?.map((e) => e.toJson()).toList(),
      'eval': instance.eval,
    };

TestQuestionAnswerResponse _$TestQuestionAnswerResponseFromJson(
        Map<String, dynamic> json) =>
    TestQuestionAnswerResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      afirm: json['afirm'] as String,
      neg: json['neg'] as String,
    );

Map<String, dynamic> _$TestQuestionAnswerResponseToJson(
        TestQuestionAnswerResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'afirm': instance.afirm,
      'neg': instance.neg,
    };
