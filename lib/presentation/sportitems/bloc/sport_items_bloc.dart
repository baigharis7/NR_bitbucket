import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/sportevents/get_today_sports_interactor.dart';
import '../../../domain/models/masterfiles/sports_info_master.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'sport_items_event.dart';

part 'sport_items_state.dart';

class SportItemsBloc extends Bloc<SportItemsEvents, SportItemsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final DeleteSportEventInteractor deleteSportEventInteractor;
  final RemoveSportEventInteractor removeSportEventInteractor;
  final UpdateEventsInteractor updateEventsInteractor;

  SportItemsBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.getTodaySportsInteractor,
    required this.deleteSportEventInteractor,
    required this.removeSportEventInteractor,
    required this.updateEventsInteractor,
  }) : super(SportItemsState(isLoading: false)) {
    on<SportItemsInitialization>((event, emit) async {
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.sportEvents = await getTodaySportsInteractor.execute(dateTime: state.dateTime);
      emit(state.copyWith(isLoading: false));

      final shouldRefresh = await updateEventsInteractor.execute(userId: getUserIdInteractor.execute(), categoryType: PrefsKeys.sportEvents, fullSync: false);
      if (shouldRefresh) {
        state.sportEvents = await getTodaySportsInteractor.execute(dateTime: state.dateTime);
        emit(state.copyWith(isLoading: false));
      }
    });

    on<UpdateDatetimeSportItemsEvents>((event, emit) async {
      state.dateTime = event.dateTime;
      state.sportEvents = await getTodaySportsInteractor.execute(dateTime: event.dateTime);

      emit(state.copyWith(isLoading: false));
    });

    on<DeleteSportItemSportItemsEvents>((event, emit) async {
      try {
        await deleteSportEventInteractor.execute(event.sportEventComplete.userId, event.sportEventComplete.eventId);
        try {
          await removeSportEventInteractor.execute(event.sportEventComplete);
          state.sportEvents = await getTodaySportsInteractor.execute(dateTime: state.dateTime);
          emit(state.copyWith(isLoading: false));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportEventError));
        }
      } catch(_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportEventError));
      }
    });
  }
}
