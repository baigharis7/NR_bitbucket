import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class UploadProfileInteractor {
  Future<UserProfileResponse> execute(UserProfileModel profile);
}