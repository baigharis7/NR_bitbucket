import 'package:nutrenaissance_flutter/domain/interactor/preferences/clear_auth_preferences_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class ClearAuthPreferencesInteractorImpl extends ClearAuthPreferencesInteractor {
  final PreferencesRepository preferencesRepository;

  ClearAuthPreferencesInteractorImpl({required this.preferencesRepository});

  @override
  Future<void> execute() => preferencesRepository.clearAuthPreferences();
}
