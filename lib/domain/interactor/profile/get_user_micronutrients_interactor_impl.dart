import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class GetUserMicronutrientsInteractorImpl extends GetUserMicronutrientsInteractor {
  final ProfileRepository profileRepository;

  GetUserMicronutrientsInteractorImpl({required this.profileRepository});

  @override
  Future<List<String>>? execute() => profileRepository.getUserMicronutrients();

}