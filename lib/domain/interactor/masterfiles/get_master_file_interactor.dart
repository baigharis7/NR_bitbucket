import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';

abstract class GetMasterFileInteractor {
  Future<dynamic> execute(MasterFilesType masterFileType);
}