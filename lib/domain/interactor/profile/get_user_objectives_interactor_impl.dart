import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

import 'get_user_objectives_interactor.dart';

class GetUserObjectivesInteractorImpl extends GetUserObjectivesInteractor {
  final ProfileRepository profileRepository;

  GetUserObjectivesInteractorImpl({required this.profileRepository});

  @override
  Future<List<int>>? execute() => profileRepository.getUserObjectives();
}