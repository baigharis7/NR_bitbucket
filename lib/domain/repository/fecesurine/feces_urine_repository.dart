import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class FecesUrineRepository {
  Future<void> uploadFeces(UploadFeces uploadFeces);
  Future<void> saveFecesEvent(UploadFeces uploadFeces);
  Future<List<UploadFeces>> getFecesEvents();
  Future<List<UploadFeces>> getFecesEventsByDate({DateTime? dateTime, DateTime? endDate, int? days});
  Future<List<UploadFeces>> getUrineEventsByDate({DateTime? dateTime, DateTime? endDate, int? days});
  Future<void> uploadUrine(UploadFeces uploadUrine);
  Future<void> saveUrineEvent(UploadFeces uploadUrine);
  Future<List<UploadFeces>> getUrineEvents();
  Future<void> deleteFecesEvent(String userId, int eventId);
  Future<void> removeFecesEvent(UploadFeces uploadFeces);
  Future<void> deleteUrineEvent(String userId, int eventId);
  Future<void> removeUrineEvent(UploadFeces uploadUrine);
}