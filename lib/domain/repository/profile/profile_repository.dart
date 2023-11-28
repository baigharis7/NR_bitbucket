import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfileResponse> uploadProfile(UserProfileModel profile);
  Future<void> saveProfile(UserProfileModel profileModel);
  Future<UserProfileModel?> getProfile();
  Future<List<String>> getUserMicronutrients();
  Future<List<int>> getUserObjectives();
  Future<bool> checkProfileExistence(String userId);
  Future<UserProfileModel?> downloadProfile(String email);
  Future<int> getUserKcal();
  Future<List<int>> getUserExclusions();
}