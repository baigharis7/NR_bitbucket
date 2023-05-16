// ignore_for_file: non_constant_identifier_names

import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'subjective_analysis_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisListEntity)
class SubjectiveAnalysisListEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<SubjectiveAnalysisEntity> data;

  SubjectiveAnalysisListEntity({
    required this.id,
    required this.v,
    required this.data,
  });

  factory SubjectiveAnalysisListEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisListEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisListEntityToJson(this);

}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisEntity)
class SubjectiveAnalysisEntity {
  @HiveField(0) final int questionId;
  @HiveField(1) final int questionType;
  @HiveField(2) final String? parameter_en;
  @HiveField(3) final String? parameter_es;
  @HiveField(4) final List<int> objectivesId;
  @HiveField(5) final SubjectiveAnalysisTestEntity? subjectiveAnalysisTestEntity_en;
  @HiveField(6) final SubjectiveAnalysisTestEntity? subjectiveAnalysisTestEntity_es;
  @HiveField(7) final String? evaluation;

  SubjectiveAnalysisEntity({
    required this.questionId,
    required this.questionType,
    required this.parameter_en,
    required this.parameter_es,
    required this.objectivesId,
    required this.subjectiveAnalysisTestEntity_en,
    required this.subjectiveAnalysisTestEntity_es,
    required this.evaluation,
  });

  factory SubjectiveAnalysisEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisTestEntity)
class SubjectiveAnalysisTestEntity {
   @HiveField(0) final String testTitle;
   @HiveField(1) final List<TestQuestionEntity> questions;

  SubjectiveAnalysisTestEntity({
    required this.testTitle,
    required this.questions,
  });

  factory SubjectiveAnalysisTestEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisTestEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisTestEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.testQuestionEntity)
class TestQuestionEntity {
  @HiveField(0) final int id;
  @HiveField(1) final String title;
  @HiveField(2) final String afirm;
  @HiveField(3) final String neg;

  TestQuestionEntity({
    required this.id,
    required this.title,
    required this.afirm,
    required this.neg,
  });

  factory TestQuestionEntity.fromJson(Map<String, dynamic> json) => _$TestQuestionEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TestQuestionEntityToJson(this);
}