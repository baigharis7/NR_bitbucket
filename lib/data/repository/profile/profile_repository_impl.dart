import 'dart:convert';

import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart' as upload;
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/profile_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileApi profileApi;
  final LocalStorageRepository localStorageRepository;
  final ProfileComputationService profileComputationService;
  final SyncQueueService syncQueue;

  ProfileRepositoryImpl({
    required this.profileApi,
    required this.localStorageRepository,
    required this.profileComputationService,
    required this.syncQueue,
  });

  @override
  Future<UserProfileResponse> uploadProfile(UserProfileModel profile) async {
    final uploadProfile = mapToUploadUserProfileModel(profile);

    // Compute locally (requires reference data from /reference-data/* endpoints)
    final localResponse = await profileComputationService.computeProfile(uploadProfile);

    if (localResponse == null) {
      throw Exception(
        'Profile computation failed: reference data not loaded. '
        'Ensure /reference-data/objective-nutrients and /reference-data/nutrient-objective endpoints are available.',
      );
    }

    // Stamp computed fields onto DTO for backend DB persistence
    uploadProfile.micronutrients = localResponse.micronutrients;
    uploadProfile.userAll = localResponse.userAll;
    uploadProfile.temporaryMicronutrients = localResponse.temporaryMicronutrients;
    uploadProfile.temporaryAll = localResponse.temporaryAll;
    uploadProfile.userRdas = localResponse.userRdas;
    uploadProfile.kcal = localResponse.kcal;

    // Fire-and-forget API call for DynamoDB persistence (don't block UI)
    _syncToBackend(uploadProfile);

    return localResponse;
  }

  void _syncToBackend(upload.UploadUserProfile uploadProfile) {
    profileApi.saveProfile(uploadProfile).catchError((error) {
      syncQueue.enqueue('/profile', uploadProfile);
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> saveProfile(UserProfileModel profileModel) async {
    final profileEntity = mapToProfileEntity(profileModel);
    localStorageRepository.saveProfile(profileEntity);
  }

  @override
  Future<UserProfileModel?> getProfile() async {
    final profileEntity = await localStorageRepository.getProfile();
    if (profileEntity.isNull()) {
      return null;
    } else {
      final profile = mapToUserProfileModelFromProfileEntity(profileEntity!);
      return UserProfileModel.fromJson(jsonDecode(jsonEncode(profile.toJson())));
    }
  }

  @override
  Future<List<String>> getUserMicronutrients() async {
    UserProfileEntity? profile = await localStorageRepository.getProfile();
    List<String>? micronutrients = profile?.micronutrients;
    return micronutrients.orEmpty();
  }

  @override
  Future<List<int>> getUserObjectives() async {
    UserProfileEntity? profile = await localStorageRepository.getProfile();
    List<int>? objectives = profile?.objectives;
    return objectives.orEmpty();
  }

  @override
  Future<bool> checkProfileExistence(String userId) async {
    return await localStorageRepository.checkProfileExistence(userId);
  }

  @override
  Future<UserProfileModel?> downloadProfile(String email) async {
    final profile = await profileApi.downloadProfile(email);
    if (profile.isEmpty) {
      return null;
    } else {
      try {
        final uploadProfile = upload.UploadUserProfile.fromJson(profile);
        return mapToUserProfileModelFromUploadUser(uploadProfile);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<int> getUserKcal() async {
    final profile = await localStorageRepository.getProfile();
    try {
      return profile!.kcal!;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<int>> getUserExclusions() async {
    final profile = await localStorageRepository.getProfile();
    try {
      return profile!.exclusions!.exclusions;
    } catch (error) {
      rethrow;
    }
  }
}