import 'package:nutrenaissance_flutter/domain/repository/explainingcards/explaining_cards_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';

class ExplainingCardsRepositoryImpl extends ExplainingCardsRepository {
  final LocalStorageRepository localStorageRepository;

  ExplainingCardsRepositoryImpl({required this.localStorageRepository});

  @override
  Future<void> saveExplainingCardInteraction(int explainingCardId) async => await localStorageRepository.saveExplainingCardInteraction(explainingCardId);

  @override
  Future<bool> isNecessaryToShowExplainingCard(int explainingCardId) async => await localStorageRepository.isNecessaryToShowExplainingCard(explainingCardId);

}