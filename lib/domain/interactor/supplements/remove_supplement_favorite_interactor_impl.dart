import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class RemoveSupplementFavoriteInteractorImpl extends RemoveSupplementFavoriteInteractor {
  final SupplementsRepository supplementsRepository;

  RemoveSupplementFavoriteInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplementFavorite) => supplementsRepository.removeSupplementFavorite(supplementFavorite);

}