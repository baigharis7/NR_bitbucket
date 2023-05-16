import 'package:nutrenaissance_flutter/data/api/analysis/subjective/model/upload_subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/analysis/subjective/upload_subjective_analysis_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/domain/repository/analysis/subjective/subjective_analysis_repository.dart';

class UploadSubjectiveAnalysisInteractorImpl extends UploadSubjectiveAnalysisInteractor {
  final SubjectiveAnalysisRepository subjectiveAnalysisRepository;

  UploadSubjectiveAnalysisInteractorImpl({required this.subjectiveAnalysisRepository});

  @override
  Future<UploadSubjectiveAnalysisResponse> execute(SubjectiveAnalysisResult subjectiveAnalysisResult) async => await subjectiveAnalysisRepository.uploadSubjectiveAnalysis(subjectiveAnalysisResult);
  
}