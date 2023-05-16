import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';

abstract class SaveMasterFileInteractor {
  Future<void> execute(dynamic masterFileResponse, MasterFilesType masterFilesType);
}