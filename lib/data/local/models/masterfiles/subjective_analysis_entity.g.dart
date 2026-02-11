// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectiveAnalysisListEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisListEntity> {
  @override
  final int typeId = 47;

  @override
  SubjectiveAnalysisListEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisListEntity(
      id: fields[0] as int,
      v: fields[1] as int,
      data: (fields[2] as List).cast<SubjectiveAnalysisEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveAnalysisListEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.v)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisListEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectiveAnalysisEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisEntity> {
  @override
  final int typeId = 48;

  @override
  SubjectiveAnalysisEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisEntity(
      questionId: fields[0] as int,
      questionType: fields[1] as int,
      parameter_en: fields[2] as String?,
      parameter_es: fields[3] as String?,
      objectivesId: (fields[4] as List).cast<int>(),
      subjectiveAnalysisTestEntity_en:
          fields[5] as SubjectiveAnalysisTestEntity?,
      subjectiveAnalysisTestEntity_es:
          fields[6] as SubjectiveAnalysisTestEntity?,
      evaluation: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveAnalysisEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.questionType)
      ..writeByte(2)
      ..write(obj.parameter_en)
      ..writeByte(3)
      ..write(obj.parameter_es)
      ..writeByte(4)
      ..write(obj.objectivesId)
      ..writeByte(5)
      ..write(obj.subjectiveAnalysisTestEntity_en)
      ..writeByte(6)
      ..write(obj.subjectiveAnalysisTestEntity_es)
      ..writeByte(7)
      ..write(obj.evaluation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectiveAnalysisTestEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisTestEntity> {
  @override
  final int typeId = 49;

  @override
  SubjectiveAnalysisTestEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisTestEntity(
      testTitle: fields[0] as String,
      questions: (fields[1] as List).cast<TestQuestionEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveAnalysisTestEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.testTitle)
      ..writeByte(1)
      ..write(obj.questions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisTestEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestQuestionEntityAdapter extends TypeAdapter<TestQuestionEntity> {
  @override
  final int typeId = 50;

  @override
  TestQuestionEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestQuestionEntity(
      id: fields[0] as int,
      title: fields[1] as String,
      afirm: fields[2] as String,
      neg: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestQuestionEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.afirm)
      ..writeByte(3)
      ..write(obj.neg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestQuestionEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisListEntity _$SubjectiveAnalysisListEntityFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisListEntity(
      id: (json['id'] as num).toInt(),
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              SubjectiveAnalysisEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisListEntityToJson(
        SubjectiveAnalysisListEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisEntity _$SubjectiveAnalysisEntityFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisEntity(
      questionId: (json['questionId'] as num).toInt(),
      questionType: (json['questionType'] as num).toInt(),
      parameter_en: json['parameter_en'] as String?,
      parameter_es: json['parameter_es'] as String?,
      objectivesId: (json['objectivesId'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      subjectiveAnalysisTestEntity_en:
          json['subjectiveAnalysisTestEntity_en'] == null
              ? null
              : SubjectiveAnalysisTestEntity.fromJson(
                  json['subjectiveAnalysisTestEntity_en']
                      as Map<String, dynamic>),
      subjectiveAnalysisTestEntity_es:
          json['subjectiveAnalysisTestEntity_es'] == null
              ? null
              : SubjectiveAnalysisTestEntity.fromJson(
                  json['subjectiveAnalysisTestEntity_es']
                      as Map<String, dynamic>),
      evaluation: json['evaluation'] as String?,
    );

Map<String, dynamic> _$SubjectiveAnalysisEntityToJson(
        SubjectiveAnalysisEntity instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'questionType': instance.questionType,
      'parameter_en': instance.parameter_en,
      'parameter_es': instance.parameter_es,
      'objectivesId': instance.objectivesId,
      'subjectiveAnalysisTestEntity_en':
          instance.subjectiveAnalysisTestEntity_en?.toJson(),
      'subjectiveAnalysisTestEntity_es':
          instance.subjectiveAnalysisTestEntity_es?.toJson(),
      'evaluation': instance.evaluation,
    };

SubjectiveAnalysisTestEntity _$SubjectiveAnalysisTestEntityFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisTestEntity(
      testTitle: json['testTitle'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => TestQuestionEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisTestEntityToJson(
        SubjectiveAnalysisTestEntity instance) =>
    <String, dynamic>{
      'testTitle': instance.testTitle,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

TestQuestionEntity _$TestQuestionEntityFromJson(Map<String, dynamic> json) =>
    TestQuestionEntity(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      afirm: json['afirm'] as String,
      neg: json['neg'] as String,
    );

Map<String, dynamic> _$TestQuestionEntityToJson(TestQuestionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'afirm': instance.afirm,
      'neg': instance.neg,
    };
