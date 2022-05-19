import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class GetProfileInteractorImpl extends GetProfileInteractor {
  final ProfileRepository profileRepository;

  GetProfileInteractorImpl({required this.profileRepository});

  // TODO: poner UserProfileModel
  Future<UserProfileModel> execute() => profileRepository.getProfile();
}