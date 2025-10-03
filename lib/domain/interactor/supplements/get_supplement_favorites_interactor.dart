import '../../models/supplements/supplement_simple.dart';

abstract class GetSupplementFavoritesInteractor {
  Future<List<SupplementSimple>> execute();
}