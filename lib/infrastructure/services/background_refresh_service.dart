import 'package:flutter/foundation.dart';

import 'package:nutrenaissance_flutter/data/api/referencedata/reference_data_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';
import 'package:nutrenaissance_flutter/main.dart' show fetchReferenceData;

/// Refreshes all S3-backed data (master files + reference data) on demand,
/// rate-limited to avoid hammering the API on quick task-switches.
///
/// Cold start already triggers refreshes via `splash_provider` and
/// `app_bootstrap`. This service additionally fires on warm resume
/// (`AppLifecycleState.resumed`) so the data isn't stuck at the cached
/// version for the entire lifetime of a backgrounded app.
class BackgroundRefreshService {
  BackgroundRefreshService._();
  static final BackgroundRefreshService instance = BackgroundRefreshService._();

  static const Duration minInterval = Duration(minutes: 5);

  MasterFilesRepository? _masterFilesRepository;
  ReferenceDataApi? _referenceDataApi;
  ReferenceDataService? _referenceDataService;
  ProfileComputationService? _profileComputationService;

  DateTime? _lastRefresh;
  bool _inFlight = false;

  void init({
    required MasterFilesRepository masterFilesRepository,
    required ReferenceDataApi referenceDataApi,
    required ReferenceDataService referenceDataService,
    required ProfileComputationService profileComputationService,
  }) {
    _masterFilesRepository = masterFilesRepository;
    _referenceDataApi = referenceDataApi;
    _referenceDataService = referenceDataService;
    _profileComputationService = profileComputationService;
    // Treat cold-start refresh (which already fires from splash + bootstrap)
    // as the most recent refresh, so we don't immediately re-fire on the
    // first resume that happens shortly after launch.
    _lastRefresh = DateTime.now();
  }

  Future<void> refreshIfStale() async {
    if (_masterFilesRepository == null) return; // not yet initialized
    if (_inFlight) return;
    final last = _lastRefresh;
    if (last != null && DateTime.now().difference(last) < minInterval) return;

    _inFlight = true;
    try {
      await Future.wait([
        _refreshMasterFiles(),
        _refreshReferenceData(),
      ]);
      _lastRefresh = DateTime.now();
    } catch (e) {
      debugPrint('BackgroundRefreshService.refreshIfStale failed: $e');
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _refreshReferenceData() async {
    final api = _referenceDataApi;
    final service = _referenceDataService;
    final profileComp = _profileComputationService;
    if (api == null || service == null || profileComp == null) return;
    fetchReferenceData(api, service, profileComp);
  }

  Future<void> _refreshMasterFiles() async {
    final repo = _masterFilesRepository;
    if (repo == null) return;
    final getVersion = GetMasterFileVersionInteractorImpl(masterFilesRepository: repo);
    final manage = ManageMasterFilesInteractorImpl(masterFilesRepository: repo);
    final save = SaveMasterFileInteractorImpl(masterFilesRepository: repo);

    final versions = await Future.wait([
      getVersion.execute(MasterFilesType.cookingMethods),
      getVersion.execute(MasterFilesType.cookingMethodsInfo),
      getVersion.execute(MasterFilesType.oilTypes),
      getVersion.execute(MasterFilesType.conversionFactors),
      getVersion.execute(MasterFilesType.conversionFactorsInfo),
      getVersion.execute(MasterFilesType.foodsAndDrinksNames),
      getVersion.execute(MasterFilesType.nutrientsInfo),
      getVersion.execute(MasterFilesType.objectivesInfo),
      getVersion.execute(MasterFilesType.recommendationGroups),
      getVersion.execute(MasterFilesType.sportsInfo),
      getVersion.execute(MasterFilesType.unitsInfo),
      getVersion.execute(MasterFilesType.unitsFoods),
      getVersion.execute(MasterFilesType.supplementsInfo),
      getVersion.execute(MasterFilesType.subjectiveAnalysis),
      getVersion.execute(MasterFilesType.cookingMethodsOilsInfo),
    ]);

    final response = await manage.execute(
      versions[0], versions[1], versions[2], versions[3], versions[4],
      versions[5], versions[6], versions[7], versions[8], versions[9],
      versions[10], versions[11], versions[12], versions[13], versions[14],
    );

    response.cookingMethodsResponse.doIfAintNull(() =>
        save.execute(response.cookingMethodsResponse, MasterFilesType.cookingMethods));
    response.cookingMethodsInfoResponse.doIfAintNull(() =>
        save.execute(response.cookingMethodsInfoResponse, MasterFilesType.cookingMethodsInfo));
    response.oilTypesResponse.doIfAintNull(() =>
        save.execute(response.oilTypesResponse, MasterFilesType.oilTypes));
    response.conversionFactorsResponse.doIfAintNull(() =>
        save.execute(response.conversionFactorsResponse, MasterFilesType.conversionFactors));
    response.conversionFactorsInfoResponse.doIfAintNull(() =>
        save.execute(response.conversionFactorsInfoResponse, MasterFilesType.conversionFactorsInfo));
    response.foodsAndDrinksNamesResponse.doIfAintNull(() =>
        save.execute(response.foodsAndDrinksNamesResponse, MasterFilesType.foodsAndDrinksNames));
    response.nutrientsInfoResponse.doIfAintNull(() =>
        save.execute(response.nutrientsInfoResponse, MasterFilesType.nutrientsInfo));
    response.objectivesResponse.doIfAintNull(() =>
        save.execute(response.objectivesResponse, MasterFilesType.objectivesInfo));
    response.recommendationGroupsResponse.doIfAintNull(() =>
        save.execute(response.recommendationGroupsResponse, MasterFilesType.recommendationGroups));
    response.sportsInfoResponse.doIfAintNull(() =>
        save.execute(response.sportsInfoResponse, MasterFilesType.sportsInfo));
    response.unitsInfoResponse.doIfAintNull(() =>
        save.execute(response.unitsInfoResponse, MasterFilesType.unitsInfo));
    response.unitsFoodsResponse.doIfAintNull(() =>
        save.execute(response.unitsFoodsResponse, MasterFilesType.unitsFoods));
    response.supplementsInfoResponse.doIfAintNull(() =>
        save.execute(response.supplementsInfoResponse, MasterFilesType.supplementsInfo));
    response.cookingMethodsOilsInfoResponse.doIfAintNull(() =>
        save.execute(response.cookingMethodsOilsInfoResponse, MasterFilesType.cookingMethodsOilsInfo));
  }
}
