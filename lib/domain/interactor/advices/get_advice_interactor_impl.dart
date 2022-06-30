import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/advices/advice.dart';
import 'package:nutrenaissance_flutter/domain/repository/advices/advices_repository.dart';

class GetAdviceInteractorImpl extends GetAdviceInteractor {
  final AdvicesRepository advicesRepository;

  GetAdviceInteractorImpl({required this.advicesRepository});

  @override
  Future<Advice> execute(String userId) => advicesRepository.getAdvice(userId);
}