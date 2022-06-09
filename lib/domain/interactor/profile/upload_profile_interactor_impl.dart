import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class UploadProfileInteractorImpl extends UploadProfileInteractor {
  final ProfileRepository profileRepository;

  UploadProfileInteractorImpl({required this.profileRepository});

  @override
  Future<UserProfileResponse> execute(UserProfileModel profile) => profileRepository.uploadProfile(profile);

}