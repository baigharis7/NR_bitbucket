import 'package:nutrenaissance_flutter/data/api/fecesurine/fece_urine_api.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class FecesUrineRepositoryImpl extends FecesUrineRepository {
  final FecesUrineApi fecesUrineApi;

  FecesUrineRepositoryImpl({required this.fecesUrineApi});

  @override
  Future<void> uploadFeces(UploadFeces uploadFeces) async {
    try {
      await fecesUrineApi.uploadFeces(uploadFeces);
    } catch (error) {
      rethrow;
    }
  }

}