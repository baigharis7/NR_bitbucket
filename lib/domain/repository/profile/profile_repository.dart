import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';

abstract class ProfileRepository {
  Future<UserProfileResponse> uploadProfile(UserProfileModel profile);
  Future<void> saveProfile(UserProfileModel profileModel);
  // TODO: poner UserProfileModel.
  Future<UserProfileModel?> getProfile();
  Future<List<String>> getUserMicronutrients();
  Future<bool> checkProfileExistence();
  Future<UserProfileModel?> downloadProfile(String email);
  Future<void> saveUserRdas(List<UserRdasResponse> userRdasResponse);
  Future<List<UserRdas>> getUserRdas();
}