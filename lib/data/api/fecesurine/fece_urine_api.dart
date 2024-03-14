import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../infrastructure/environment/environment.dart';

class FecesUrineApi extends ApiHelper {
  FecesUrineApi(super.preferencesRepository, super.authenticationService, super.chuck);

  Future<Map<String, dynamic>> uploadFeces(UploadFeces uploadFeces) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/feces',
        ),
        uploadFeces,
      );

  Future<Map<String, dynamic>> uploadUrineEvent(UploadFeces uploadUrine) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/urine',
        ),
        uploadUrine,
      );

  Future<Map<String, dynamic>> deleteFecesEvent(String userId, int eventId) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/feces',
        ),
        {
          'userId': userId,
          'eventId': eventId,
        },
      );

  Future<Map<String, dynamic>> deleteUrineEvent(String userId, int eventId) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/urine',
        ),
        {
          'userId': userId,
          'eventId': eventId,
        },
      );

}