import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class DownloadProfileInteractor {
  Future<UserProfileModel?> execute(String email);
}