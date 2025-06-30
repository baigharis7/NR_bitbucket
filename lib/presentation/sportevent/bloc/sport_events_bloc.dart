import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';

import '../../../domain/interactor/routines/save_routine_interactor.dart';
import '../../../domain/interactor/routines/upload_routine_interactor.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class SportEventsBloc extends BaseBloc<SportEventsActions, SportEventsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;
  final UploadSportEventsInteractor uploadSportsEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final UploadRoutineInteractor uploadRoutineInteractor;
  final SaveRoutineInteractor saveRoutineInteractor;

  SportEventsBloc({
    required this.getUserIdInteractor,
    required this.saveSportEventInteractor,
    required this.uploadSportsEventInteractor,
    required this.getMasterFileInteractor,
    required this.getSportFavoritesInteractor,
    required this.getWeekSportsInteractor,
    required this.uploadRoutineInteractor,
    required this.saveRoutineInteractor,
  }) : super(SportEventsState(
    isLoading: false,
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    isEdit: false,
    sportSimpleEvent: AddSportFavorite.empty(),
    info: [],
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      _clearFields();
      // state.sportEventSimple?.userId = getUserIdInteractor.execute();
      final sportInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.sportsInfo = sportInfo;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetIntensityAction>((event, emit) {
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info![itemIndex].intensity = event.sportInfo.intensity;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetMinutesAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info![itemIndex].minutes = event.sportInfo.minutes;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSportEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.sportSimpleEvent?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info!.indexOf(state.sportSimpleEvent!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info!.remove(state.sportSimpleEvent!.info![itemIndex]);
        state.sportSimpleEvent!.info!.add(event.sportInfo);
      } else {
        state.sportSimpleEvent?.info?.add(event.sportInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<RemoveSportEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.sportSimpleEvent?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info!.indexOf(state.sportSimpleEvent!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info!.remove(state.sportSimpleEvent!.info![itemIndex]);
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishSportEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      state.sportSimpleEvent?.userId = getUserIdInteractor.execute();
      state.sportSimpleEvent?.eventId = DateTime.now().millisecondsSinceEpoch;
      state.sportSimpleEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
      final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(state.sportSimpleEvent!);

        // final sportEventSimple = SportEventSimple(
        //   userId: getUserIdInteractor.execute(),
        //   eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        //   info: state.info,
        //   comment: '',
        //   sportName: '',
        // );

        try {
          final sportEventComplete = await uploadSportsEventInteractor.execute(sportEventSimple);
          try {
            await saveSportEventInteractor.execute(sportEventComplete, state.isEdit ?? false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            state.onError = ErrorTypes.locallySavingSportEventError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
          }
        } catch (error) {
          state.onError = ErrorTypes.uploadingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      });

    on<FinishSportRoutineAddSportAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      final sportRoutineEvent = mapAddFavSportToSportRoutineCompleted(state.sportSimpleEvent!);
      sportRoutineEvent.userId = getUserIdInteractor.execute();
      sportRoutineEvent.eventId = DateTime.now().millisecondsSinceEpoch;
      sportRoutineEvent.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
      sportRoutineEvent.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
        // final sportRoutineEvent = SportRoutineCompleted(
        //   userId: getUserIdInteractor.execute(),
        //   eventId: DateTime.now().millisecondsSinceEpoch,
        //   eventDate: state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        //   info: [],
        //   comment: '',
        //   sportName: '',
        // );

        try {
          final sportEventComplete = await uploadRoutineInteractor.execute(sportRoutineEvent);
          try {
            // await saveSportEventInteractor.execute(sportEventComplete, false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            state.onError = ErrorTypes.locallySavingSportEventError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
          }
        } catch (error) {
          state.onError = ErrorTypes.uploadingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      });

    on<ResetSportInfoAction>((event, emit) {
      _clearFields();
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateCalendarDateSportEventAction>((event, emit) {
      state.calendarDate = event.calendarDate;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateDaysOfWeekSportEventAction>((event, emit) {
      final daysOfWeek = state.sportSimpleEvent?.daysOfWeek.orEmpty() ?? [];
      // if (daysOfWeek.contains(event.weekDay)) {
      //   state.sportSimpleEvent?.daysOfWeek?.remove(event.weekDay);
      // } else {
      //   state.sportSimpleEvent?.daysOfWeek?.add(event.weekDay);
      // }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateTimeOfDaySportEventAction>((event, emit) {
      state.sportSimpleEvent?.scheduleTime = event.scheduleTime;

      emit(state.copyWith(isLoading: false));
    });
  }


  SportInfoMaster findSportByName(String name, String currentLanguage) {
    final sport = state.sportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport;
  }

  int findSportIdByName(String name, String currentLanguage) {
    final sport = state.sportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport.id;
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
    }

  int calculateMillisecondsStart(TimeOfDay timeStart, DateTime dateStart) {
    DateTime dateTime = DateTime(dateStart.year, dateStart.month, dateStart.day, timeStart.hour, timeStart.minute);
    return dateTime.millisecondsSinceEpoch;
  }

  void _clearFields() {
    state.sportSimpleEvent = AddSportFavorite.empty();
    state.info = [];
    state.isEdit = false;
    state.eventDate = null;
  }

  bool? validateSportList() {
    return state.info?.any((sport) {
      return sport.minutes == null || sport.intensity == null || sport.timeStart == null;
    },);
  }

  void addFrequentFromWeek(List<SportEventComplete> sportList, List<AddSportFavorite> favoriteList) {
    for (int i = 0; i < sportList.length; i++) {
      int count = 1;
      for (int j = i + 1; j < sportList.length; j++) {
        SportEventComplete selectedItem = sportList[i];
        SportEventComplete matchableItem = sportList[j];
        if (areFoodInfoListsEqual(selectedItem.info!, matchableItem.info!)) {
          count = count + 1;
        }
      }
      if (count == 3) {
        favoriteList.add(mapToSportFavoriteFromEventComplete(sportList[i]));
      }
    }
  }

  bool areFoodInfoListsEqual(List<SportEventInfo> list1, List<SportEventInfo> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (!areFoodInfoObjectsEqual(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }
  bool areFoodInfoObjectsEqual(SportEventInfo obj1, SportEventInfo obj2) {
    return (obj1.id == obj2.id && obj1.intensity == obj2.intensity && obj1.minutes == obj2.minutes);
  }
}