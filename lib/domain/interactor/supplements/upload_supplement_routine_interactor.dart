import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';

abstract class UploadSupplementRoutineInteractor {
  Future<void> execute(UploadSupplementRoutine uploadSupplementRoutine);
}