import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class GetUrineByDateInteractor {
  Future<List<UploadFeces>> execute({DateTime? dateTime, int? prevDays});
}