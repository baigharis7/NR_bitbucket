import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';

class SaveExplainingCardInteractionInteractorImpl extends SaveExplainingCardInteractionInteractor {
  final ExplainingCardsRepository explainingCardsRepository;

  SaveExplainingCardInteractionInteractorImpl({required this.explainingCardsRepository});

  @override
  Future<void> execute(int explainingCardId) async => await explainingCardsRepository.saveExplainingCardInteraction(explainingCardId);

}