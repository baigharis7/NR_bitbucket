import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class AdvicesApi extends ApiHelper {

  AdvicesApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> getAdvice(String userId) =>
      get(
          Uri.https(
              Environment().config!.baseUrl,
              '${Environment().config!.distributionPath}/advices',
            {Constants.USERID_QUERY: userId.toString()}
          ),
      );
}