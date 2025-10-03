import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class SaveSupplementEventInteractor {
  Future<void> execute(SupplementSimple supplementSimple, bool isEdit);
}