import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/analysis/subjective/model/subjective_analysis_result_request.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class SubjectiveAnalysisApi extends ApiHelper {
  SubjectiveAnalysisApi(
      PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService,
      Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadSubjectiveAnalysis(SubjectiveAnalysisResultRequest subjectiveAnalysisResultRequest) =>
      post(
        Uri.https(
            Environment().config!.baseUrl,
            '${Environment().config!.distributionPath}/subjective-analysis',
        ),
        subjectiveAnalysisResultRequest,
      );
}