import 'package:nutrenaissance_flutter/domain/interactor/preferences/save_username_and_email_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class SaveUsernameAndEmailInteractorImpl extends SaveUsernameAndEmailInteractor{
  final PreferencesRepository preferencesRepository;

  SaveUsernameAndEmailInteractorImpl({required this.preferencesRepository});

  @override
  void execute(String username, String email) => preferencesRepository.setUsernameAndEmail(username, email);
}