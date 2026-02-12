import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

/// API client for fetching reference data used by client-side calculations.
///
/// These endpoints serve the S3 files that were previously only accessed
/// by Lambda functions:
/// - `nutrients.json` — full nutrient composition per food/drink
/// - `nutrients_loss_table.json` — nutrient retention loss per cooking method
///
/// **Backend requirement**: Create these two endpoints in API Gateway/Lambda
/// that read from the S3 `nutrients-pro` bucket and return the JSON arrays
/// with a version wrapper: `{ "v": <int>, "data": [...] }`
class ReferenceDataApi extends ApiHelper {
  ReferenceDataApi(
    PreferencesRepository preferencesRepository,
    AuthenticationService authenticationService,
    Chuck chuck,
  ) : super(preferencesRepository, authenticationService, chuck);

  /// Fetches the full nutrient composition database.
  /// Returns raw JSON string: `{ "v": <int>, "data": [ { "id": 1, "params": {...} }, ... ] }`
  Future<String> fetchNutrients() {
    return getRaw(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/reference-data/nutrients',
      ),
    );
  }

  /// Fetches the nutrient loss table.
  /// Returns raw JSON string: `{ "v": <int>, "data": [ { "cookingMethodId": 1, "nutrients": {...} }, ... ] }`
  Future<String> fetchNutrientLossTable() {
    return getRaw(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/reference-data/nutrient-loss',
      ),
    );
  }

  /// Fetches the full sport METs database (with METs arrays per intensity).
  /// Returns raw JSON string: `{ "v": <int>, "data": [ { "id": 1, "mets": ["3,5", "7,0", ...] }, ... ] }`
  Future<String> fetchSportMets() {
    return getRaw(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/reference-data/sport-mets',
      ),
    );
  }
}
