import 'package:nutrenaissance_flutter/data/api/advices/advices_api.dart';
import 'package:nutrenaissance_flutter/data/api/advices/model/advice_response.dart';
import 'package:nutrenaissance_flutter/domain/models/advices/advice.dart';
import 'package:nutrenaissance_flutter/domain/repository/advices/advices_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/advice_mappers.dart';

class AdvicesRepositoryImpl extends AdvicesRepository {
  final AdvicesApi advicesApi;

  AdvicesRepositoryImpl({required this.advicesApi});

  @override
  Future<Advice> getAdvice(String userId) async {
    final advicesResponse = AdviceResponse.fromJson(await advicesApi.getAdvice(userId));
    return mapToAdviceFromResponse(advicesResponse);
  }

}