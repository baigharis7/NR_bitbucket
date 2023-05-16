import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class GetMasterFileVersionInteractorImpl extends GetMasterFileVersionInteractor {
  final MasterFilesRepository masterFilesRepository;

  GetMasterFileVersionInteractorImpl({required this.masterFilesRepository});

  @override
  Future<int> execute(MasterFilesType masterFileType) async => masterFilesRepository.getMasterFileVersion(masterFileType);

}