import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
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

import '../../../domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import '../../../domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import '../../../domain/interactor/routines/save_routine_interactor.dart';
import '../../../domain/interactor/routines/upload_routine_interactor.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/utils/crashlytics_service.dart';

class SportEventsBloc extends BaseBloc<SportEventsActions, SportEventsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;
  final UploadSportEventsInteractor uploadSportsEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final UploadRoutineInteractor uploadRoutineInteractor;
  final SaveRoutineInteractor saveRoutineInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;
  final DeleteSportFavoriteInteractor deleteSportFavoriteInteractor;
  final RemoveSportFavoriteInteractor removeSportFavoriteInteractor;

  SportEventsBloc({
    required this.getUserIdInteractor,
    required this.saveSportEventInteractor,
    required this.uploadSportsEventInteractor,
    required this.getMasterFileInteractor,
    required this.getSportFavoritesInteractor,
    required this.getWeekSportsInteractor,
    required this.uploadRoutineInteractor,
    required this.saveRoutineInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
    required this.deleteSportFavoriteInteractor,
    required this.removeSportFavoriteInteractor,
  }) : super(SportEventsState(
    isLoading: false,
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    isEdit: false,
    sportSimpleEvent: AddSportFavorite.empty(),
    favSports: [],
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      _clearFields();
      // state.sportEventSimple?.userId = getUserIdInteractor.execute();
      final sportInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.sportsInfo = sportInfo;
      final favSports = await getSportFavoritesInteractor.execute();
      state.favSports = favSports;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateCalendarDateSportEventAction>((event, emit) {
      state.calendarDate = event.calendarDate;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSportArgumentModelEventAction>((event, emit) {
      state.calendarDate = event.sportArgumentsModel.selectedDateTime;
      if (event.sportArgumentsModel.preSelectFavorite) {
        state.sportSimpleEvent?.isFavorite = true;
      }
      if (event.sportArgumentsModel.preSelectRoutine) {
        state.sportSimpleEvent?.isCreateRoutine = true;
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

    on<SetMinutesAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.sportSimpleEvent!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info.orEmpty().indexOf(state.sportSimpleEvent!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info.orEmpty()[itemIndex].minutes = event.sportInfo.minutes;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetIntensityAction>((event, emit) {
      if (state.sportSimpleEvent!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info.orEmpty().indexOf(state.sportSimpleEvent!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info.orEmpty()[itemIndex].intensity = event.sportInfo.intensity;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetEventSportNameAction>((event, emit) {
      state.sportSimpleEvent?.title = event.sportEventName;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateIsFavoriteSportEventsActions>((event, emit) {
      state.sportSimpleEvent?.isFavorite = event.isFavorite;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateIsCreateRoutineSportEventsActions>((event, emit) {
      state.sportSimpleEvent?.isCreateRoutine = event.isCreateRoutine;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateTimeOfDaySportEventAction>((event, emit) {
      state.sportSimpleEvent?.scheduleTime = event.scheduleTime;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateDaysOfWeekSportEventAction>((event, emit) {
      // final daysOfWeek = state.sportSimpleEvent?.daysOfWeek.orEmpty() ?? [];
      // if (state.sportSimpleEvent?.daysOfWeek.orEmpty().contains(event.weekDay) ?? false) {
      //   state.sportSimpleEvent?.daysOfWeek?.remove(event.weekDay);
      // } else {
      //   state.sportSimpleEvent?.daysOfWeek?.add(event.weekDay);
      // }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSportFavoriteFromFavoriteEvent>((event, emit) {
      final isSame = state.sportFavoriteEvent == event.sportFavorite;
      state.sportFavoriteEvent = isSame ? null : event.sportFavorite;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportFromFavoriteTabSportEventsActions>((event, emit) {
      state.sportSimpleEvent = event.addSportFavorite;
      state.calendarDate = DateTimeHelper.dateTimeFromMilliseconds(event.addSportFavorite.eventDate);
      state.isEdit = true;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportFromRoutinesTabSportEventsActions>((event, emit) {
      final item = mapToSportFavoriteFromRoutine(event.sportRoutineCompleted);
      item.isCreateRoutine = true;
      state.sportSimpleEvent = item;
      state.isEdit = true;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishSportEventActions>((event, emit) async {
      state.sportSimpleEvent?.userId = getUserIdInteractor.execute();
      state.sportSimpleEvent?.eventId = state.sportSimpleEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
      state.sportSimpleEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
      state.sportSimpleEvent?.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
      if (state.sportSimpleEvent?.isFavorite == true) {
        add(FinishSportFavouriteAddSportAction(sportFavorite: state.sportSimpleEvent!, onFinish: event.onFinish));
      }
      else if (state.sportSimpleEvent?.isCreateRoutine == true && state.sportSimpleEvent!.daysOfWeek.orEmpty().isNotEmpty && state.sportSimpleEvent!.scheduleTime.orEmpty().isNotEmpty) {
        final sportRoutineCompleted = mapAddFavSportToSportRoutineCompleted(state.sportSimpleEvent!);
        add(FinishSportRoutineAddSportAction(sportRoutineCompleted: sportRoutineCompleted,onFinish: event.onFinish));
      } else {
        final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(state.sportSimpleEvent!);
        add(FinishSportEventAction(sportEventSimple: sportEventSimple, onFinish: event.onFinish));
      }
    });

    on<FinishSportEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

        try {
          event.sportEventSimple.userId = getUserIdInteractor.execute();

          final sportEventComplete = await uploadSportsEventInteractor.execute(event.sportEventSimple);
          try {
            await saveSportEventInteractor.execute(sportEventComplete, false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error, st) {
            state.onError = ErrorTypes.locallySavingSportEventError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Sport logging local',
                'screen': 'Add Sport',
                'event data': event.sportEventSimple.toJson().toString(),
              },
            );
          }
        } catch (error, st) {
          state.onError = ErrorTypes.uploadingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Sport logging',
              'screen': 'Add Sport',
              'event data': event.sportEventSimple.toJson().toString(),
            },
          );
        }
      });

    on<FinishSportRoutineAddSportAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

        try {
          event.sportRoutineCompleted.userId = getUserIdInteractor.execute();
          event.sportRoutineCompleted.timeZone = await DateTimeHelper.getDeviceIANATimeZone();

          final sportEventComplete = await uploadRoutineInteractor.execute(event.sportRoutineCompleted);
          try {
            await saveRoutineInteractor.execute(event.sportRoutineCompleted, state.isEdit ?? false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error, st) {
            state.onError = ErrorTypes.locallySavingSportRoutineError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Sport routine logging local',
                'screen': 'Add Sport',
                'event data': event.sportRoutineCompleted.toJson().toString(),
              },
            );
          }
        } catch (error, st) {
          state.onError = ErrorTypes.uploadingSportRoutineError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Sport routine logging',
              'screen': 'Add Sport',
              'event data': event.sportRoutineCompleted.toJson().toString(),
            },
          );
        }
      });

    on<FinishSportFavouriteAddSportAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        event.sportFavorite.userId = getUserIdInteractor.execute();

        final uploadResult = await uploadSportFavoriteInteractor.execute(event.sportFavorite);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(event.sportFavorite, state.isEdit ?? false);
          state.favSports = await getSportFavoritesInteractor.execute();

          _clearFields();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null,));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSportFavoriteError));
        }
      } catch (error, st) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSportFavoriteError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Sport favorite logging',
            'screen': 'Add Sport',
            'event data': event.sportFavorite.toJson().toString(),
          },
        );
      }
    });

    on<FinishSportFavoriteActions>((event, emit) {
      state.sportFavoriteEvent?.eventId = DateTime.now().millisecondsSinceEpoch;
      state.sportFavoriteEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
      if (state.sportFavoriteEvent?.isCreateRoutine == true && state.sportFavoriteEvent!.daysOfWeek.orEmpty().isNotEmpty && state.sportFavoriteEvent!.scheduleTime.orEmpty().isNotEmpty) {
        final sportRoutineCompleted = mapAddFavSportToSportRoutineCompleted(state.sportFavoriteEvent!);
        add(FinishSportRoutineAddSportAction(sportRoutineCompleted: sportRoutineCompleted,onFinish: event.onFinish));
      } else {
        final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(state.sportFavoriteEvent!);
        add(FinishSportEventAction(sportEventSimple: sportEventSimple, onFinish: event.onFinish));
      }
    });

    on<DeleteFavSportSportEventsAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final userId = getUserIdInteractor.execute();
      try {
        final deleteFavorite = await deleteSportFavoriteInteractor.execute(userId, event.sportFavorite.eventId!);
        if (deleteFavorite) {
          try {
            final removeFromLocalResult = await removeSportFavoriteInteractor.execute(event.sportFavorite);
            if (removeFromLocalResult) {
              state.favSports = await getSportFavoritesInteractor.execute();
              event.onFinish.call();
              emit(state.copyWith(isLoading: false, onError: null));
            } else {
              emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
            }
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
      }
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
    state.sportSimpleEvent = AddSportFavorite.empty(eventData: state.sportSimpleEvent?.eventDate);
    state.sportFavoriteEvent = AddSportFavorite.empty(eventData: state.sportSimpleEvent?.eventDate);
    state.isEdit = false;
  }

  bool? validateSportList() {
    return state.sportSimpleEvent?.info?.any((sport) {
      return sport.minutes.orZero() <= 0 || sport.intensity == null;
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