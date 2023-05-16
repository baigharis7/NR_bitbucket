import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/api/analysis/subjective/subjective_analysis_api.dart';
import 'package:nutrenaissance_flutter/data/repository/analysis/subjective/subjective_analysis_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/preferences/preferences_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/analysis/subjective/upload_subjective_analysis_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/analysis/subjective/upload_subjective_analysis_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_actions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestBloc extends Bloc<TestActions, TestState> {
  TestBloc() : super(TestState(namesSelected: [])) {

    on<SelectOption>((event, emit) async {
      final repository = SubjectiveAnalysisRepositoryImpl(localStorageRepository: LocalStorageImpl(), subjectiveAnalysisApi: SubjectiveAnalysisApi(PreferencesRepositoryImpl(prefs: PreferencesImpl(await SharedPreferences.getInstance())), await CognitoAuthenticationService.init()));
      final UploadSubjectiveAnalysisInteractor interactor = UploadSubjectiveAnalysisInteractorImpl(subjectiveAnalysisRepository: repository);
      final subjectiveData = SubjectiveAnalysisResult(
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        userId: GetUserIdInteractorImpl(preferencesRepository: PreferencesRepositoryImpl(prefs: PreferencesImpl(await SharedPreferences.getInstance()))).execute(),
        questionList: [
          SubjectiveAnalysisAnswerResult(
            questionId: 0,
            value: 89,
          ),
          SubjectiveAnalysisAnswerResult(
            questionId: 5,
            testAnswerList: [
              SubjectiveAnalysisTestAnswer(
                testQuestionId: 0,
                answersType: AnswersType.positive.index,
              ),
              SubjectiveAnalysisTestAnswer(
                testQuestionId: 1,
                answersType: AnswersType.negative.index,
              ),
              SubjectiveAnalysisTestAnswer(
                testQuestionId: 2,
                answersType: AnswersType.positive.index,
              ),
            ],
          )
        ],
      );

      emit(state);
    });
  }

}