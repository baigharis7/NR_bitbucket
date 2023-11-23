import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
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
        eventDate: DateTime.now().millisecondsSinceEpoch,
        title: state.favoriteSportName,
        comment: state.comment,
        info: state.info,
      );

      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(sportFavorite, false);

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
  }

  void _resetSportInfo() {
    state.info?.clear();
    state.eventDate = null;
    state.favoriteSportName = null;
    state.comment = null;
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
  }

}