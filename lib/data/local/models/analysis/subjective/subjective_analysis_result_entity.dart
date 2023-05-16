import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'subjective_analysis_result_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisResultEntity)
class SubjectiveAnalysisResultEntity extends HiveObject {
  static const boxName = 'subjective_analysis';

  @HiveField(0) String userId;
  @HiveField(1) int eventDate;
  @HiveField(2) List<SubjectiveAnalysisAnswerResultEntity> questionList;

  SubjectiveAnalysisResultEntity({
    required this.userId,
    required this.eventDate,
    required this.questionList,
  });

  factory SubjectiveAnalysisResultEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisResultEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisResultEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisAnswerResultEntity)
class SubjectiveAnalysisAnswerResultEntity {
  @HiveField(0) int questionId;
  @HiveField(1) int? value;
  @HiveField(2) List<SubjectiveAnalysisTestAnswerResultEntity>? testAnswerList;

  SubjectiveAnalysisAnswerResultEntity({
    required this.questionId,
    this.value,
    this.testAnswerList,
  });

  factory SubjectiveAnalysisAnswerResultEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisAnswerResultEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisAnswerResultEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.subjectiveAnalysisTestAnswerResultEntity)
class SubjectiveAnalysisTestAnswerResultEntity {
  @HiveField(0) int testQuestionId;
  @HiveField(1) int answersType;

  SubjectiveAnalysisTestAnswerResultEntity({
    required this.testQuestionId,
    required this.answersType,
  });

  factory SubjectiveAnalysisTestAnswerResultEntity.fromJson(Map<String, dynamic> json) => _$SubjectiveAnalysisTestAnswerResultEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectiveAnalysisTestAnswerResultEntityToJson(this);
}