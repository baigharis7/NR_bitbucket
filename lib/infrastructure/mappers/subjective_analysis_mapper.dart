import 'package:nutrenaissance_flutter/data/api/analysis/subjective/model/subjective_analysis_result_request.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';

SubjectiveAnalysisResultRequest mapToSubjectiveAnalysisResultRequest(SubjectiveAnalysisResult subjectiveAnalysisResult) {
  return SubjectiveAnalysisResultRequest(
    userId: subjectiveAnalysisResult.userId,
    eventDate: subjectiveAnalysisResult.eventDate,
    questionList: subjectiveAnalysisResult.questionList.map((question) => SubjectiveAnalysisAnswerRequest(
      questionId: question.questionId,
      value: question.value,
      testAnswerList: question.testAnswerList?.map((answer) => SubjectiveAnalysisTestAnswerRequest(
        testQuestionId: answer.testQuestionId,
        answersType: answer.answersType,
      ),).toList(),
    ),).toList(),
  );
}

SubjectiveAnalysisResultEntity mapToSubjectiveAnalysisResultsEntity(SubjectiveAnalysisResult subjectiveAnalysisResult) {
  return SubjectiveAnalysisResultEntity(
    userId: subjectiveAnalysisResult.userId,
    eventDate: subjectiveAnalysisResult.eventDate,
    questionList: subjectiveAnalysisResult.questionList.map((question) => SubjectiveAnalysisAnswerResultEntity(
      questionId: question.questionId,
      value: question.value,
      testAnswerList: question.testAnswerList?.map((answer) => SubjectiveAnalysisTestAnswerResultEntity(
          testQuestionId: answer.testQuestionId, answersType: answer.answersType,
      ),).toList(),
    ),).toList(),
  );
}