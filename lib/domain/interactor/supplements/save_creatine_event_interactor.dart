import '../../../data/api/supplements/model/upload_supplement_event.dart';

abstract class SaveCreatineEventInteractor {
  Future<void> execute(UploadSupplementEvent uploadSupplementCreatineEvent, bool isEdit);
}