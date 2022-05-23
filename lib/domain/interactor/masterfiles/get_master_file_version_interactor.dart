import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';

abstract class GetMasterFileVersionInteractor {
  Future<int> execute(MasterFilesType masterFileType);
}