import 'package:nutrenaissance_flutter/domain/interactor/profile/download_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class DownloadProfileInteractorImpl extends DownloadProfileInteractor {
  final ProfileRepository profileRepository;

  DownloadProfileInteractorImpl({required this.profileRepository});

  @override
  Future<UserProfileModel?> execute(String email) => profileRepository.downloadProfile(email);

}