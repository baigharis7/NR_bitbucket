import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

abstract class GetUserRdasInteractor {
  Future<List<UserRda>> execute();
}