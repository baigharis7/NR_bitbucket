import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_rdas_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';

List<UserRdasEntity> mapToUserRdasEntity(List<UserRdasResponse> userRdasResponse) {
  return userRdasResponse.map((rda) => UserRdasEntity(
      n: rda.n,
      rda: rda.rda.toDouble(),
      ul: rda.ul.toDouble()
  )).toList();
}

List<UserRdas> mapToUserRdas(List<dynamic> userRdasEntity) {
  return userRdasEntity.map((rda) => UserRdas(
      name: rda.n,
      rda: rda.rda.toDouble(),
      ul: rda.ul.toDouble()
  )).toList();
}
