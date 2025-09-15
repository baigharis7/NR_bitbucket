import '../../../data/api/fecesurine/models/upload_feces.dart';

abstract class GetFaecesByDateInteractor {
  Future<List<UploadFeces>> execute({DateTime? dateTime, DateTime? endDate, int? days});
}