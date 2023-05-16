import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class GetUserKcalInteractorImpl extends GetUserKcalInteractor {
  final ProfileRepository profileRepository;

  GetUserKcalInteractorImpl({required this.profileRepository});

  @override
  Future<int> execute() async => profileRepository.getUserKcal();

}
