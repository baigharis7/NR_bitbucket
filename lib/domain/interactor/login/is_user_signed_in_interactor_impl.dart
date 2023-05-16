import 'package:nutrenaissance_flutter/domain/interactor/login/is_user_signed_in_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class IsUserSignedInInteractorImpl extends IsUserSignedInInteractor{
  final PreferencesRepository preferencesRepository;

  IsUserSignedInInteractorImpl({required this.preferencesRepository});

  @override
  Future<bool> execute() => preferencesRepository.isUserSignedIn();

}