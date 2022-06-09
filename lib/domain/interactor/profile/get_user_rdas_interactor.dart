import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';

abstract class GetUserRdasInteractor {
  Future<List<UserRdas>> execute();
}