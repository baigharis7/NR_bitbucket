import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class UploadSupplementFavoriteInteractorImpl extends UploadSupplementFavoriteInteractor {
  final SupplementsRepository supplementsRepository;

  UploadSupplementFavoriteInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementFavorite supplementFavorite) => supplementsRepository.uploadSupplementFavorite(supplementFavorite);

}