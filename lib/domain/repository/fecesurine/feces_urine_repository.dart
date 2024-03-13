import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

abstract class FecesUrineRepository {
  Future<void> uploadFeces(UploadFeces uploadFeces);
  Future<void> saveFecesEvent(UploadFeces uploadFeces);
  Future<List<UploadFeces>> getFecesEvents();
}