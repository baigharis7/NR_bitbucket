import 'dart:async';
import 'package:chuck_interceptor/chuck.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class EventsSyncApi extends ApiHelper {
  EventsSyncApi(
      PreferencesRepository preferencesRepository,
      AuthenticationService authenticationService,
      Chuck chuck)
      : super(preferencesRepository, authenticationService, chuck);

  /// List of valid category names
  static const List<String> validCategories = [
    'foodEvents',
    'foodRoutines',
    'sportEvents',
    'sportRoutines',
    'liquidEvents',
    'waterEvents',
    'foodFavorites',
    'sportFavorites',
    'liquidFavorites',
    'subjectiveAnalysis',
    'recipeFavorites',
    'fecesEvents',
    'urineEvents',
    'creatineEvents',
    'collagenEvents',
    'supplementEvents',
    'supplementFavorites',
    'supplementRoutines',
  ];

  /// Internal helper to send POST requests
  Future<Map<String, dynamic>> _sync(
      String userId, Map<String, dynamic> payload) {
    return post(
      Uri.https(
        Environment().config!.baseUrl,
        '${Environment().config!.distributionPath}/events-sync-test',
      ),
      {
        'userId': userId,
        ...payload,
      },
    );
  }

  /// Sync a single category by sending only the IDs to skip
  Future<Map<String, dynamic>> syncCategory(
      String userId, String categoryName, List<String> idsToSkip) {
    if (!validCategories.contains(categoryName)) {
      throw ArgumentError(
          'Invalid category name: $categoryName. Must be one of $validCategories');
    }

    return _sync(userId, {
      categoryName: idsToSkip,
    });
  }

  /// Batch sync categories using a map
  Future<Map<String, dynamic>> syncAllData(
      String userId, Map<String, List<String>> categoriesData) {
    // Validate keys
    for (var key in categoriesData.keys) {
      if (!validCategories.contains(key)) {
        throw ArgumentError(
            'Invalid category name in batch: $key. Must be one of $validCategories');
      }
    }

    return _sync(userId, categoriesData);
  }
}
