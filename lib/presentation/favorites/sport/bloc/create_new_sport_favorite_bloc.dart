import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
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
    sportFavorite: SportFavorite.empty(),
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetSportIdAction>((event, emit) {
      state.sportId = event.sportId;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetMinutesAction>((event, emit) {
      state.minutes = event.minutes;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetIntensityAction>((event, emit) {
      state.intensity = event.intensity;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetTimeStartAction>((event, emit) {
      state.timeStart = event.timeOfDay;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetSportFavoriteNameAction>((event, emit) {
      state.favoriteSportName = event.favoriteName;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishCreateSportFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      // TODO: controlar error de firstWhere.
      final sportInfo = state.sportsInfo!.sportsInfoMaster.firstWhere((sportInfo) => sportInfo.id == state.sportId);

      final sportFavorite = SportFavorite(
        id: state.sportId,
        minutes: state.minutes,
        intensity: state.intensity,
        timeStart: '${state.timeStart!.hour}:${state.timeStart!.minute}',
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        title: state.favoriteSportName,
        name_en: sportInfo.en,
        name_es: sportInfo.es,
      );

      final userId = getUserIdInteractor.execute();
      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite, userId);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(sportFavorite, false);
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
    state.sportFavorite = SportFavorite.empty();
    state.eventDate = null;
    state.timeStart = null;
    state.favoriteSportName = null;
    state.intensity = null;
    state.sportIntensities = null;
    state.sportId = null;
    state.minutes = null;
    state.sportFavorite = SportFavorite.empty();
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
  }

}