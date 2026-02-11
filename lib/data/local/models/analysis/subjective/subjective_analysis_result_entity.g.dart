// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjective_analysis_result_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectiveAnalysisResultEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisResultEntity> {
  @override
  final int typeId = 51;

  @override
  SubjectiveAnalysisResultEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisResultEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      questionList:
          (fields[2] as List).cast<SubjectiveAnalysisAnswerResultEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveAnalysisResultEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.questionList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisResultEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectiveAnalysisAnswerResultEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisAnswerResultEntity> {
  @override
  final int typeId = 52;

  @override
  SubjectiveAnalysisAnswerResultEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisAnswerResultEntity(
      questionId: fields[0] as int,
      value: fields[1] as int?,
      testAnswerList: (fields[2] as List?)
          ?.cast<SubjectiveAnalysisTestAnswerResultEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveAnalysisAnswerResultEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.testAnswerList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisAnswerResultEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectiveAnalysisTestAnswerResultEntityAdapter
    extends TypeAdapter<SubjectiveAnalysisTestAnswerResultEntity> {
  @override
  final int typeId = 53;

  @override
  SubjectiveAnalysisTestAnswerResultEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveAnalysisTestAnswerResultEntity(
      testQuestionId: fields[0] as int,
      answersType: fields[1] as int,
    );
  }

  @override
  void write(
      BinaryWriter writer, SubjectiveAnalysisTestAnswerResultEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.testQuestionId)
      ..writeByte(1)
      ..write(obj.answersType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveAnalysisTestAnswerResultEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectiveAnalysisResultEntity _$SubjectiveAnalysisResultEntityFromJson(
        Map<String, dynamic> json) =>
    SubjectiveAnalysisResultEntity(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      questionList: (json['questionList'] as List<dynamic>)
          .map((e) => SubjectiveAnalysisAnswerResultEntity.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectiveAnalysisResultEntityToJson(
        SubjectiveAnalysisResultEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'questionList': instance.questionList.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisAnswerResultEntity
    _$SubjectiveAnalysisAnswerResultEntityFromJson(Map<String, dynamic> json) =>
        SubjectiveAnalysisAnswerResultEntity(
          questionId: (json['questionId'] as num).toInt(),
          value: (json['value'] as num?)?.toInt(),
          testAnswerList: (json['testAnswerList'] as List<dynamic>?)
              ?.map((e) => SubjectiveAnalysisTestAnswerResultEntity.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$SubjectiveAnalysisAnswerResultEntityToJson(
        SubjectiveAnalysisAnswerResultEntity instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'value': instance.value,
      'testAnswerList':
          instance.testAnswerList?.map((e) => e.toJson()).toList(),
    };

SubjectiveAnalysisTestAnswerResultEntity
    _$SubjectiveAnalysisTestAnswerResultEntityFromJson(
            Map<String, dynamic> json) =>
        SubjectiveAnalysisTestAnswerResultEntity(
          testQuestionId: (json['testQuestionId'] as num).toInt(),
          answersType: (json['answersType'] as num).toInt(),
        );

Map<String, dynamic> _$SubjectiveAnalysisTestAnswerResultEntityToJson(
        SubjectiveAnalysisTestAnswerResultEntity instance) =>
    <String, dynamic>{
      'testQuestionId': instance.testQuestionId,
      'answersType': instance.answersType,
    };
