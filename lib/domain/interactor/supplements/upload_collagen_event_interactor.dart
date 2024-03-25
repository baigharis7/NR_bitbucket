import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';

abstract class UploadCollagenEventInteractor {
  Future<void> execute(UploadSupplementEvent uploadSupplementCollagenEvent,);
}