import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';

class IsNecessaryToShowExplainingCardInteractorImpl extends IsNecessaryToShowExplainingCardInteractor {
  final ExplainingCardsRepository explainingCardsRepository;

  IsNecessaryToShowExplainingCardInteractorImpl({
    required this.explainingCardsRepository,
  });

  @override
  Future<bool> execute(int explainingCardId) async => await explainingCardsRepository.isNecessaryToShowExplainingCard(explainingCardId);
}