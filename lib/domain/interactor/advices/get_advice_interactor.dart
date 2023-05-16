import 'package:nutrenaissance_flutter/domain/models/advices/advice.dart';

abstract class GetAdviceInteractor {
  Future<Advice> execute(String userId);
}