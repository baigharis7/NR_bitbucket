import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class GetProfileInteractor {
  // TODO: poner UserProfileModel
  Future<UserProfileModel?> execute();
}