import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';

abstract class SaveMasterFileInteractor {
  void execute(dynamic masterFile, MasterFilesType masterFilesType);
}