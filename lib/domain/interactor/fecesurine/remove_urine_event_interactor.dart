import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class RemoveUrineEventInteractor {
  Future<void> execute(UploadFeces uploadUrine);
}