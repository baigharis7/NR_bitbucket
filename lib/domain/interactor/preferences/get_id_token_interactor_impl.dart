
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

import 'get_id_token_interactor.dart';

class GetIdTokenInteractorImpl extends GetIdTokenInteractor {
  final PreferencesRepository preferencesRepository;

  GetIdTokenInteractorImpl({required this.preferencesRepository});

  @override
  String execute() => preferencesRepository.getIdToken();

}