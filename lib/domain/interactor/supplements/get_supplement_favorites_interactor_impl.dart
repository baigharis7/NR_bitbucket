import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

import '../../models/supplements/supplement_simple.dart';

class GetSupplementFavoritesInteractorImpl extends GetSupplementFavoritesInteractor {
  final SupplementsRepository supplementsRepository;

  GetSupplementFavoritesInteractorImpl({required this.supplementsRepository});

  @override
  Future<List<SupplementSimple>> execute() => supplementsRepository.getSupplementFavorite();

}