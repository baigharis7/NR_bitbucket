import '../../models/profile/user_profile_model.dart';
import '../../repository/profile/profile_repository.dart';
import 'save_profile_entity_interactor.dart';

class SaveProfileInteractorImpl extends SaveProfileInteractor {
  final ProfileRepository profileRepository;

  SaveProfileInteractorImpl({required this.profileRepository});

  @override
  Future<void> execute(UserProfileModel profile) => profileRepository.saveProfile(profile);

}