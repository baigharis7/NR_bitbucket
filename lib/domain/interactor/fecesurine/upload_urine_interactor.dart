import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class UploadUrineInteractor {
  Future<void> execute(UploadFeces uploadUrine);
}