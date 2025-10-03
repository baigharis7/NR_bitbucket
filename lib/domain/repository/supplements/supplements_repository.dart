import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class SupplementsRepository {
  Future<void> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent);
  Future<void> saveCreatineEvent(UploadSupplementEvent uploadSupplementCreatineEvent, bool isEdit);
  Future<UploadSupplementEvent?> getTodayCreatineEvent({DateTime? dateTime});
  Future<UploadSupplementEvent?> getTodayCollagenEvent({DateTime? dateTime});
  Future<void> uploadCollagenEvent(UploadSupplementEvent uploadSupplementCollagenEvent,);
  Future<void> saveCollagenEvent(UploadSupplementEvent uploadSupplementCollagenEvent, bool isEdit);
  Future<List<UploadSupplementEvent>> getAllCreatineEvents();
  Future<List<UploadSupplementEvent>> getAllCollagenEvents();

  //New
  Future<void> uploadSupplementEvent(UploadSupplementsEv uploadSupplementsEv);
  Future<void> saveSupplementEvent(SupplementSimple supplementSimple, bool isEdit);
  Future<List<SupplementSimple>> getSupplementEventsDay({DateTime? dateTime});
  Future<void> deleteSupplementEvent(SupplementSimple supplementEvent);
  Future<void> removeSupplementEvent(SupplementSimple supplementEvent);
}