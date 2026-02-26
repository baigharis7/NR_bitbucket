import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class GetRecentSupplementItemsInteractor {
  Future<List<SupplementSimple>> execute();
}
