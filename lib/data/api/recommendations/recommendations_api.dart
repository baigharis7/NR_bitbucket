import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class RecommendationsApi extends ApiHelper {
  RecommendationsApi({
    required GetIdTokenInteractor getIdTokenInteractor,
    required FetchUserAttributesInteractor fetchUserAttributesInteractor
  }) : super(getIdTokenInteractor, fetchUserAttributesInteractor);

  Future<Map<String, dynamic>> getRecommendation(String userId) =>
      get(
        Uri.https(
          Environment().config!.baseUrl,
          '/dev/recommendations',
          {Constants.USERID_QUERY: userId.toString()},
        ),
      );

}