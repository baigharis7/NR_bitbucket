import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class LogMealTokenApi extends ApiHelper {
  LogMealTokenApi(super.preferencesRepository, super.authenticationService, super.chuck);

  Future<Map<String, dynamic>> getOrCreateToken(String userId) => post(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/logmeal-user-token',
    ),
    {'userId': userId},
  );
}
