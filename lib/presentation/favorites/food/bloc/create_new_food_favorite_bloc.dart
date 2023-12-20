import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_state.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class CreateNewFoodFavoriteBloc extends BaseBloc<CreateNewFoodFavoriteActions, CreateNewFoodFavoriteState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;

  CreateNewFoodFavoriteBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodFavoriteInteractor,
  }) : super(CreateNewFoodFavoriteState(isLoading: false)) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.foodsInFavorite = [];

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<RemoveFoodFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      state.foodsInFavorite!.remove(event.foodInFavorite);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddFoodFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite!.remove(state.foodsInFavorite![itemIndex]);
        state.foodsInFavorite!.add(event.foodInFavorite);
      } else {
        state.foodsInFavorite!.add(event.foodInFavorite);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateQuantityAction>((event, emit) {
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].qty = event.foodInFavorite.qty;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateUnitAction>((event, emit) {
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].unit = event.foodInFavorite.unit;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateCookingMethodAction>((event, emit){
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].cookingMethod = event.foodInFavorite.cookingMethod;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddFoodNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishFoodFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.foodsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
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
  }

  bool isFoodFavValidateList() {
      return state.foodsInFavorite?.any((foodFav) { return foodFav.qty <= 0; },) ?? true;
  }
}