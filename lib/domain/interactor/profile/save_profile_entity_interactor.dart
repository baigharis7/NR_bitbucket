import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class SaveProfileInteractor {
  Future<void> execute(UserProfileModel profile);
}