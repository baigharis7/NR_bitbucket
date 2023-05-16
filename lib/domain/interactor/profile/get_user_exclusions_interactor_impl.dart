import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class GetUserExclusionsInteractorImpl extends GetUserExclusionsInteractor {
  final ProfileRepository profileRepository;

  GetUserExclusionsInteractorImpl({required this.profileRepository});

  @override
  Future<List<int>> execute() async => await profileRepository.getUserExclusions();

}