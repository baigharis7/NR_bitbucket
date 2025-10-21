import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SaveSupplementFavoriteInteractorImpl extends SaveSupplementFavoriteInteractor {
  final SupplementsRepository supplementsRepository;

  SaveSupplementFavoriteInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementFavorite supplementFavorite, bool isEdit) => supplementsRepository.saveSupplementFavorite(supplementFavorite, isEdit);
}