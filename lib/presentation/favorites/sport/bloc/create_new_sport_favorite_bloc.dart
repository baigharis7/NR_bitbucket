import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_state.dart';

class CreateNewSportFavoriteBloc extends BaseBloc<CreateNewSportFavoriteActions, CreateNewSportFavoriteState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;

  CreateNewSportFavoriteBloc({
    required this.getMasterFileInteractor,
    required this.getUserIdInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
  }) : super(CreateNewSportFavoriteState(
    isLoading: false,
    onError: null,
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    info: [],
  ),) {
    on<InitializeStateAction>((event, emit) async {
      _resetSportInfo();
      emit(state.copyWith(isLoading: true, onError: null));
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddFavSportAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.info!.map((sport) => sport.id).contains((event.addSportFavInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.addSportFavInfo.id));
        state.info!.remove(state.info![itemIndex]);
        state.info!.add(event.addSportFavInfo);
      } else {
        state.info!.add(event.addSportFavInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<RemoveSportFavAction>((event, emit) {
      if (state.info!.map((sport) => sport.id).contains((event.addSportFavInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.addSportFavInfo.id));
        state.info!.remove(state.info![itemIndex]);
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateMinutesSportFavAction>((event, emit) {
      if (state.info!.map((sport) => sport.id).contains((event.addSportFavInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.addSportFavInfo.id));
        state.info![itemIndex].minutes = event.addSportFavInfo.minutes;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateIntensitySportFavAction>((event, emit) {
      if (state.info!.map((sport) => sport.id).contains((event.addSportFavInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.addSportFavInfo.id));
        state.info![itemIndex].intensity = event.addSportFavInfo.intensity;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateTimeStartSportFavAction>((event, emit) {
      if (state.info!.map((sport) => sport.id).contains((event.addSportFavInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.addSportFavInfo.id));
        state.info![itemIndex].timeStart = event.addSportFavInfo.timeStart;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportFavoriteNameAction>((event, emit) {
      state.favoriteSportName = event.favoriteSportName;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishCreateSportFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      // TODO: controlar error de firstWhere.
      // final sportInfo = state.sportsInfo!.sportsInfoMaster.firstWhere((sportInfo) => sportInfo.id == state.sportId);

      final sportFavorite = AddSportFavorite(
        userId: getUserIdInteractor.execute(),
        eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        title: state.favoriteSportName,
        comment: state.comment,
        info: state.info,
      );

      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(sportFavorite, state.isEdit ?? false);

          _resetSportInfo();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null,));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    });

    on<ResetFavoriteSportInfoAction>((event, emit) {
      _resetSportInfo();

      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<UpdateCreateRoutineAction>((event, emit) {
      state.isCreateRoutine = (state.isCreateRoutine ?? false) ? false : true;

      emit(state.copyWith(isLoading: false));
    },);

    on<SetDataFromDetailNaviAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.eventDate = event.favoritesSport.eventDate;
      state.info = event.favoritesSport.info;
      state.comment = event.favoritesSport.comment;
      state.favoriteSportName = event.favoritesSport.title;
      state.isEdit = true;
      state.isCreateRoutine = !event.favoritesSport.routineTime.isNull();
      state.routineHour = DateTimeHelper.timeOfDayFromMillis(int.tryParse(event.favoritesSport.routineTime.orEmpty()));
      state.routineDate = DateTimeHelper.dateTimeFromMilliseconds(int.tryParse(event.favoritesSport.routineTime.orEmpty()));

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateRoutineHourAction>((event, emit) {
      state.routineHour = event.timeOfDay;

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateRoutineDateAction>((event, emit) {
      state.routineDate = event.dateTime;

      emit(state.copyWith(isLoading: false));
    },);

    on<FinishCreateRoutineAction>((event, emit) async {
      final sportFavorite = AddSportFavorite(
        userId: getUserIdInteractor.execute(),
        eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        title: state.favoriteSportName,
        comment: state.comment,
        info: state.info,
        routineTime: DateTimeHelper.calculateMillisecondsFromTimeOfDayDateTime(state.routineHour, state.routineDate).toString(),
      );

      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(sportFavorite, state.isEdit ?? false);

          _resetSportInfo();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null,));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<FinishSportFavWithoutCreateRoutineAction>((event, emit) async {
      for (AddSportFavInfo sport in state.info.orEmpty()) {
        emit(state.copyWith(isLoading: true));
        final favSportName = sport.translate(event.context);

        final sportFavorite = AddSportFavorite(
          userId: getUserIdInteractor.execute(),
          eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
          title: favSportName,
          comment: state.comment,
          info: state.info,
        );

        try {
          final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite);
          if (uploadResult) {
            await saveSportFavoriteInteractor.execute(sportFavorite, state.isEdit ?? false);

            // _resetSportInfo();
            // event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null,));
          } else {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
          }
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      }

      if (state.info.orEmpty().isNotEmpty) event.onFinish.call();
    },);
  }

  void _resetSportInfo() {
    state.info?.clear();
    state.eventDate = null;
    state.favoriteSportName = null;
    state.comment = null;
    state.isCreateRoutine = null;
    state.isEdit = null;
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
  }

  bool? validateFavSportList() {
    return state.info?.any((sport) {
      return sport.minutes == null || sport.intensity == null || sport.timeStart == null;
    },);
  }

}