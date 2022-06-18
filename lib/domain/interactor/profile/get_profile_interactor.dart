import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class GetProfileInteractor {
  Future<UserProfileModel?> execute();
}