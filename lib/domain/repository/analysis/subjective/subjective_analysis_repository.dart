import 'package:nutrenaissance_flutter/data/api/analysis/subjective/model/upload_subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';

abstract class SubjectiveAnalysisRepository {
  Future<UploadSubjectiveAnalysisResponse> uploadSubjectiveAnalysis(SubjectiveAnalysisResult subjectiveAnalysisResult);
  Future<bool> saveSubjectiveAnalysis(SubjectiveAnalysisResult subjectiveAnalysisResult);
}