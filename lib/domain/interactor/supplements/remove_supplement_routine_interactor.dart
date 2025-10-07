import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class RemoveSupplementRoutineInteractor {
  Future<void> execute(SupplementSimple supplement);
}