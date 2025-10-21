import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class DeleteSupplementEventInteractor {
  Future<void> execute(SupplementSimple supplementEvent);
}