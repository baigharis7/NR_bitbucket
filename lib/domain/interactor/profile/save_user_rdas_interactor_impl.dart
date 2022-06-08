import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';

class SaveUserRdasInteractorImpl extends SaveUserRdasInteractor {
  final ProfileRepository profileRepository;

  SaveUserRdasInteractorImpl({required this.profileRepository});

  @override
  Future<void> execute(List<UserRdasResponse> userRdas) async => await profileRepository.saveUserRdas(userRdas);

}