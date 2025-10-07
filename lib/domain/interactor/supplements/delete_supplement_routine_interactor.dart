import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class DeleteSupplementRoutineInteractor {
  Future<void> execute(SupplementSimple supplement);
}