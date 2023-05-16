import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/manage_master_files_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/masterfiles/master_files_repository.dart';

class ManageMasterFilesInteractorImpl extends ManageMasterFilesInteractor {
  final MasterFilesRepository masterFilesRepository;

  ManageMasterFilesInteractorImpl({required this.masterFilesRepository});

  @override
  Future<MasterFilesResponse> execute(
      int cookingMethodsInfoVersion,
      int cookingMethodsVersion,
      int foodsAndDrinksNamesVersion,
      int nutrientsInfoVersion,
      int objectivesInfoVersion,
      int recommendationGroupsVersion,
      int sportsInfoVersion,
      int unitsInfoVersion,
      int unitsFoodsVersion,
      int subjectiveAnalysisVersion,
  ) async {
    return masterFilesRepository.manageMasterFiles(
      cookingMethodsVersion,
      cookingMethodsInfoVersion,
      foodsAndDrinksNamesVersion,
      nutrientsInfoVersion,
      objectivesInfoVersion,
      recommendationGroupsVersion,
      sportsInfoVersion,
      unitsInfoVersion,
      unitsFoodsVersion,
      subjectiveAnalysisVersion,
    );
  }

}