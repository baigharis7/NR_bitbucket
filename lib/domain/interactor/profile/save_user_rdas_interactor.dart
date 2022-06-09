import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';

abstract class SaveUserRdasInteractor {
  Future<void> execute(List<UserRdasResponse> userRdas);
}