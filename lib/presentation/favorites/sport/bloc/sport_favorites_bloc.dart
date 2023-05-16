import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_state.dart';

class SportFavoritesBloc extends BaseBloc<SportFavoritesActions, SportFavoritesState> {
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final DeleteSportFavoriteInteractor deleteSportFavoriteInteractor;
  final RemoveSportFavoriteInteractor removeSportFavoriteInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  SportFavoritesBloc({
    required this.getSportFavoritesInteractor,
    required this.deleteSportFavoriteInteractor,
    required this.removeSportFavoriteInteractor,
    required this.getUserIdInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(SportFavoritesState(
    isLoading: false,
    sportFavorites: [],
    showCard: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.sportFavorites = await getSportFavoritesInteractor.execute();
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.addSportFavorite.index);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<RemoveFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final userId = getUserIdInteractor.execute();
      try {
        final deleteFavorite = await deleteSportFavoriteInteractor.execute(userId, event.sportFavorite.eventDate!);
        if (deleteFavorite) {
          try {
            final removeFromLocalResult = await removeSportFavoriteInteractor.execute(event.sportFavorite, userId);
            if (removeFromLocalResult) {
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

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.addSportFavorite.index);

      emit(state.copyWith(isLoading: false));
    });
  }

}