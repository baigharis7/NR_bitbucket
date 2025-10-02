import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';

abstract class UploadSupplementEventInteractor {
  Future<void> execute(UploadSupplementsEv uploadSupplementsEv);
}