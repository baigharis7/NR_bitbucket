import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart' as upload;
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/profile_mappers.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileApi profileApi;
  final LocalStorageRepository localStorageRepository;

  ProfileRepositoryImpl({required this.profileApi, required this.localStorageRepository});

  @override
  Future<UserProfileResponse> uploadProfile(UserProfileModel profile) async {
    final uploadProfile = mapToUploadUserProfileModel(profile);
    final upload = await profileApi.uploadProfileApi(uploadProfile);
    return UserProfileResponse.fromJson(upload);
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
      return mapToUserProfileModelFromProfileEntity(profileEntity!);
    }
  }

  @override
  Future<List<String>> getUserMicronutrients() async {
    UserProfileEntity? profile = await localStorageRepository.getProfile();
    List<String>? micronutrients = profile?.micronutrients;
    return micronutrients.orEmpty();
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