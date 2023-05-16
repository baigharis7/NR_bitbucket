import 'package:nutrenaissance_flutter/domain/interactor/profile/check_profile_existence_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class CheckProfileExistenceInteractorImpl extends CheckProfileExistenceInteractor {
  final ProfileRepository profileRepository;

  CheckProfileExistenceInteractorImpl({required this.profileRepository});

  @override
  Future<bool> execute(String userId) => profileRepository.checkProfileExistence(userId);

}