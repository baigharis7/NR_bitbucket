import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class GetFecesEventsInteractor {
  Future<List<UploadFeces>> execute();
}