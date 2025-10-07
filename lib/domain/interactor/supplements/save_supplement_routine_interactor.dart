import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';

abstract class SaveSupplementRoutineInteractor {
  Future<void> execute(UploadSupplementRoutine supplementRoutine);
}