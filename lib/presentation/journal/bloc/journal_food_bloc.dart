import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_state.dart';

import '../../../domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import '../../../domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import '../../../domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../infrastructure/errors/error_types.dart';

class JournalFoodBloc extends BaseBloc<JournalFoodActions, JournalFoodState> {
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetUserKcalInteractor getUserKcalInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;

  JournalFoodBloc({
    required this.getFoodEventsOfTodayInteractor,
    required this.getFoodFavoritesInteractor,
    required this.getWeekFoodEventsInteractor,
    required this.getUserKcalInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodFavoriteInteractor,
    required this.getUserIdInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
    required this.deleteFoodFavoriteInteractor,
  }) : super(JournalFoodState(
    isLoading: false,
    todayFoodEvents: [],
    foodFavorites: [],
    weeklyData: [],
    userKcal: 0,
    showCard: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.userKcal = await getUserKcalInteractor.execute();
      state.todayFoodEvents = await getFoodEventsOfTodayInteractor.execute();
      state.foodFavorites = await getFoodFavoritesInteractor.execute();
      final completeWeekData = await getWeekFoodEventsInteractor.execute();
      state.weeklyData = getWeeklyDataFormatted(completeWeekData);
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.addNewFoodEvent.index);

      emit(state.copyWith(isLoading: false));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.addNewFoodEvent.index);

      emit(state.copyWith(isLoading: false));
    });

    on<AddFoodNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));
      List<FoodInFavorite>? ingredients = event.foodEvent.foodInfo?.map((ingredient) => FoodInFavorite(id: ingredient.id!, name_en: ingredient.name_en!, name_es: ingredient.name_es!, qty: ingredient.eventInfo?.qty?.toInt() ?? 0, unit: ingredient.eventInfo?.unit ?? 0, cookingMethod: ingredient.eventInfo?.cookingMethod ?? 0)).toList();

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: event.foodEvent.eventDate ?? DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: ingredients ?? [],
        drinks: [],
        mealTime: state.mealTime!,
        comment: event.foodEvent.comment,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, false);
            event.onFinish.call();
            emit(state.copyWith(isLoading: false));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
      }
    });

    on<RemoveFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodFavoriteInteractor.execute(getUserIdInteractor.execute(), event.foodFavorite.eventDate);
        try {
          await removeFoodFavoriteFromLocalInteractor.execute(event.foodFavorite);
          state.foodFavorites = await getFoodFavoritesInteractor.execute();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    });
  }

  List<Map<String, dynamic>> getWeeklyDataFormatted(List<FoodEventComplete> completeWeekData) {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in completeWeekData) {
      int weekDay = DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <FoodEventComplete>[];
      for (var event in completeWeekData) {
        final eventDate = DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfWeekDay.add(event);
        }
      }
      int kcalConsumed = 0;
      for (var event in eventsOfWeekDay) {
        kcalConsumed = kcalConsumed + event.eventKcals!;
      }

      weeklyData.add({'day': eventWeekDay, 'kcal': EventsHelper().getFractionToFillKcal(kcalConsumed, state.userKcal!)});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }


  bool isFoodFavourite(FoodEventComplete foodEvent) {
    // List<FoodFavorite> favFoodList = state.foodFavorites!;
    var isFavourite = false;

    // for (FoodFavorite favFood in favFoodList) {
    //   isFavourite = favFood.title.contains(foodEvent.foodName.toString());
    //   if(isFavourite) {
    //     break;
    //   }
    //   // for (FoodInFavorite favFoodItem in favFood.ingredients) {
    //   //   for(FoodInfo food in foodEvent.foodInfo ?? []) {
    //   //     isFavourite = favFoodItem.name_en == food.name_es && favFoodItem.cookingMethod == food.eventInfo?.cookingMethod && food.eventInfo?.qty?.toDouble() == favFoodItem.qty.toDouble();
    //   //     }
    //   // }
    // }


    parentLoop:for (FoodFavorite favFood in state.foodFavorites ?? []) {

      if (favFood.ingredients.length == (foodEvent.foodInfo?.length ?? 0)) {
        childLoop:for (FoodInfo foodInfoItem in foodEvent.foodInfo!) {
          isFavourite = favFood.ingredients.any((ingredientItem) => ingredientItem.id == foodInfoItem.id && ingredientItem.cookingMethod == foodInfoItem.eventInfo!.cookingMethod && ingredientItem.qty == foodInfoItem.eventInfo!.qty);
          if (!isFavourite) break childLoop;
        }
      }
    }

    return isFavourite;
  }

}