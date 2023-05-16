import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class GetUserIdInteractorImpl extends GetUserIdInteractor{
  final PreferencesRepository preferencesRepository;

  GetUserIdInteractorImpl({required this.preferencesRepository});

  @override
  String execute() => preferencesRepository.getSub();

}