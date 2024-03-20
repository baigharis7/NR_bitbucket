import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';

abstract class SupplementsRepository {
  Future<void> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent);
  Future<void> saveCreatineEvent();
  Future<UploadSupplementEvent> getTodayCreatineEvent();
}