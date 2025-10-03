import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class RemoveSupplementEventInteractor {
  Future<void> execute(SupplementSimple supplementEvent);
}