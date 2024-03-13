import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class SaveFecesEventInteractor {
  Future<void> execute(UploadFeces uploadFeces);
}