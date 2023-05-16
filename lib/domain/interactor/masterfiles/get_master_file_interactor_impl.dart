import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class GetMasterFileInteractorImpl extends GetMasterFileInteractor {
  final MasterFilesRepository masterFilesRepository;

  GetMasterFileInteractorImpl({required this.masterFilesRepository});

  @override
  Future? execute(MasterFilesType masterFileType) async {
    final masterFile = await masterFilesRepository.getMasterFile(masterFileType);
    return masterFile;
  }
}