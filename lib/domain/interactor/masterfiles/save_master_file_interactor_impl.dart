import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/save_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class SaveMasterFileInteractorImpl extends SaveMasterFileInteractor {
  final MasterFilesRepository masterFilesRepository;

  SaveMasterFileInteractorImpl({required this.masterFilesRepository});

  @override
  Future<void> execute(masterFileResponse, MasterFilesType masterFilesType) => masterFilesRepository.saveMasterFile(masterFileResponse, masterFilesType);

}