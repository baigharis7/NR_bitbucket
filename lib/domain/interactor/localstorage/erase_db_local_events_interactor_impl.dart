import 'package:nutrenaissance_flutter/domain/interactor/localstorage/erase_db_local_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';

class EraseDBLocalEventsInteractorImpl extends EraseDBLocalEventsInteractor {
  final LocalStorageRepository localStorageRepository;

  EraseDBLocalEventsInteractorImpl({required this.localStorageRepository});

  @override
  Future<bool> execute() => localStorageRepository.eraseDBEventsData();

}