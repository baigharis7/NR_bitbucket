import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

import '../../../infrastructure/environment/environment.dart';

class SupplementApi extends ApiHelper {

  SupplementApi(PreferencesRepository preferencesRepository, AuthenticationService authenticationService, Chuck chuck) : super(preferencesRepository, authenticationService, chuck);

  Future<Map<String, dynamic>> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/creatine',
        ),
        uploadSupplementEvent,
      );

  Future<Map<String, dynamic>> uploadCollagenEvent(UploadSupplementEvent uploadSupplementCollagenEvent) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/collagen',
        ),
        uploadSupplementCollagenEvent,
      );

  Future<Map<String, dynamic>> uploadSupplementEvent(UploadSupplementsEv uploadSupplementsEv) =>
      post(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/supplements',
        ),
        uploadSupplementsEv,
      );

  Future<Map<String, dynamic>> deleteSupplementEvent(SupplementSimple supplementEvent) =>
      delete(
        Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}/supplements',
        ),
        {
          'userId': supplementEvent.userId,
          'eventId': supplementEvent.eventId,
        },
      );

}