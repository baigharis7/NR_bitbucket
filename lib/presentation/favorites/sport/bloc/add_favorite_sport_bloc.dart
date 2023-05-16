import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_state.dart';

class AddFavoriteSportBloc extends BaseBloc<AddFavoriteSportActions, AddFavoriteSportState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;

  AddFavoriteSportBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
  }) : super(AddFavoriteSportState(
    isLoading: false,
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    sportFavorite: SportFavorite.empty(),
    isEdit: false,
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteAction>((event, emit) {
      state.sportFavorite = event.sportFavorite;
      state.isEdit = true;

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteCommentAction>((event, emit) {
      state.sportFavorite!.comment = event.comment;
      event.onFinish.call();

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteNameAction>((event, emit) {
      state.sportFavorite!.title = event.favoriteName;

      emit(state.copyWith(isLoading: false));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final userId = getUserIdInteractor.execute();
      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(state.sportFavorite!, userId);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(state.sportFavorite!, state.isEdit ?? false);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    });


  }

  String getIntensityName(BuildContext context, int? intensity) {
    switch (intensity) {
      case 0: return AppLocalizations.of(context)!.low;
      case 1: return AppLocalizations.of(context)!.medium;
      case 2: return AppLocalizations.of(context)!.high;
      default: return '';
    }
  }
}