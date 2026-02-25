import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class FcmApi extends ApiHelper {
  FcmApi(super.preferencesRepository, super.authenticationService, super.chuck);

  Future<void> registerToken(String userId, String token, String platform) => post(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/fcm-token',
    ),
    {'userId': userId, 'token': token, 'platform': platform},
  );

  Future<void> unregisterToken(String token) => delete(
    Uri.https(
      Environment().config!.baseUrl,
      '${Environment().config!.distributionPath}/fcm-token',
    ),
    {'token': token},
  );
}
