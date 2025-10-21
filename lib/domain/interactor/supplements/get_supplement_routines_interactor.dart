import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class GetSupplementRoutinesInteractor {
  Future<List<SupplementSimple>> execute();
}