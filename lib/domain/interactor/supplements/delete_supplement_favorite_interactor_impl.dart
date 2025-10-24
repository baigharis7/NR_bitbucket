import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class DeleteSupplementFavoriteInteractorImpl extends DeleteSupplementFavoriteInteractor {
  final SupplementsRepository supplementsRepository;

  DeleteSupplementFavoriteInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplementFavorite) => supplementsRepository.deleteSupplementFavorite(supplementFavorite);

}