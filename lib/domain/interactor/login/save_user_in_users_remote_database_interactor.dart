import 'package:nutrenaissance_flutter/data/api/profile/model/simple_user.dart';

abstract class SaveUserInUsersRemoteDatabaseInteractor {
  void execute(SimpleUser simpleUser);
}