import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SupplementsRepositoryImpl extends SupplementsRepository {
  final SupplementApi supplementApi;
  final LocalStorageRepository localStorageRepository;


  SupplementsRepositoryImpl({required this.supplementApi, required this.localStorageRepository});

  @override
  Future<UploadSupplementEvent> getTodayCreatineEvent() async {
    try {

      return UploadSupplementEvent(userId: '', eventId: -1, value: 0);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveCreatineEvent() {
    // TODO: implement saveCreatineEvent
    throw UnimplementedError();
  }

  @override
  Future<void> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent) async {
    try {
      await supplementApi.uploadCreatineEvent(uploadSupplementEvent);
    } catch (error) {
      rethrow;
    }
  }

}