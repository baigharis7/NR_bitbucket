import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';

abstract class SaveUserInUsersRemoteDatabaseInteractor {
  Future<void> execute(SimpleUser simpleUser);
}