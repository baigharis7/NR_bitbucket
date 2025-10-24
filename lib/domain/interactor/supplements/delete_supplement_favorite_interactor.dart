import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class DeleteSupplementFavoriteInteractor {
  Future<void> execute(SupplementSimple supplementFavorite);
}