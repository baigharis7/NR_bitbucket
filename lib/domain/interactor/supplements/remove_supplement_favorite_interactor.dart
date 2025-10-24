import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class RemoveSupplementFavoriteInteractor {
  Future<void> execute(SupplementSimple supplementFavorite);
}