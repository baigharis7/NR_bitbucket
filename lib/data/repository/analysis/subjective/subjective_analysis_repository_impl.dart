import 'package:nutrenaissance_flutter/data/api/analysis/subjective/model/upload_subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/data/api/analysis/subjective/subjective_analysis_api.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/domain/repository/analysis/subjective/subjective_analysis_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/subjective_analysis_mapper.dart';

class SubjectiveAnalysisRepositoryImpl extends SubjectiveAnalysisRepository {
  final LocalStorageRepository localStorageRepository;
  final SubjectiveAnalysisApi subjectiveAnalysisApi;

  SubjectiveAnalysisRepositoryImpl({
    required this.localStorageRepository,
    required this.subjectiveAnalysisApi,
  });

  @override
  Future<bool> saveSubjectiveAnalysis(SubjectiveAnalysisResult subjectiveAnalysisResult) async {
    try {
      await localStorageRepository.saveSubjectiveAnalysis(subjectiveAnalysisResult);
      return true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UploadSubjectiveAnalysisResponse> uploadSubjectiveAnalysis(SubjectiveAnalysisResult subjectiveAnalysisResult) async {
    // TODO: map to request.
    final subjectiveAnalysisResultRequest = mapToSubjectiveAnalysisResultRequest(subjectiveAnalysisResult);
    final uploadResponse = await subjectiveAnalysisApi.uploadSubjectiveAnalysis(subjectiveAnalysisResultRequest);
    return UploadSubjectiveAnalysisResponse.fromJson(uploadResponse);
  }

}