import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class GetUrineEventsInteractor {
  Future<List<UploadFeces>> execute();
}