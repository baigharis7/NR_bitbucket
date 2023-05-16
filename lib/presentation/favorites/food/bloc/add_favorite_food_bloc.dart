import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_state.dart';

class AddFavoriteFoodBloc extends BaseBloc<AddFavoriteFoodActions, AddFavoriteFoodState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;

  AddFavoriteFoodBloc({
    required this.getMasterFileInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodFavoriteInteractor,
  }) : super(AddFavoriteFoodState(
    isLoading: false,
    onError: null,
    foodsInFavorite: [],
    foodNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])),
    cookingMethodsMaster: CookingMethodsMaster(cookingMethods: []),
    cookingMethodsInfoMaster: CookingMethodsInfoMaster(cookingMethodsInfo: []),
    unitsInfoMaster: UnitsInfoMaster(unitsInfoMaster: []),
    unitsFoodsMaster: UnitsFoodsMaster(unitsFoodsMaster: []),
    favoriteName: '',
    isEdit: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetFoodsInFavoriteAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null));

      state.foodsInFavorite = event.foodsInFavorite;
      emit(state.copyWith(isLoading: false,));
    });

    on<AddCommentToFavoriteActions>((event, emit) {
      state.comment = event.comment;

      event.onFinish.call();
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

    on<SetFoodFavoriteToEditAction>((event, emit) {
      emit(state.copyWith(isLoading: true));

      state.favoriteName = event.foodFavorite.title;
      state.mealTime = event.foodFavorite.mealTime;
      state.comment = event.foodFavorite.comment;
      state.foodsInFavorite = event.foodFavorite.ingredients;
      state.isEdit = true;
      state.eventDate = event.foodFavorite.eventDate;

      emit(state.copyWith(isLoading: false));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: state.eventDate ?? DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.foodsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
        comment: state.comment,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, state.isEdit!);
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

}