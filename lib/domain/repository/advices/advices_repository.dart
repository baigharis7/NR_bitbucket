import 'package:nutrenaissance_flutter/domain/models/advices/advice.dart';

abstract class AdvicesRepository {
  Future<Advice> getAdvice(String userId);

}