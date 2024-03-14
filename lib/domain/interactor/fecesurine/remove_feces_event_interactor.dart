import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class RemoveFecesEventInteractor {
  Future<void> execute(UploadFeces uploadFeces);
}