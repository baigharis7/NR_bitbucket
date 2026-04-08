import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/save_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/upload_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_state.dart';

class AddFavoriteLiquidBloc extends BaseBloc<AddFavoriteLiquidActions, AddFavoriteLiquidState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveLiquidFavoriteInteractor saveLiquidFavoriteInteractor;
  final UploadLiquidFavoriteInteractor uploadLiquidFavoriteInteractor;

  AddFavoriteLiquidBloc({
    required this.getMasterFileInteractor,
    required this.saveLiquidFavoriteInteractor,
    required this.uploadLiquidFavoriteInteractor,
  }) : super(AddFavoriteLiquidState(
    isLoading: false,
    onError: null,
    liquidsInFavorite: [],
    liquidNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])),
    cookingMethodsMaster: CookingMethodsMaster(cookingMethods: []),
    cookingMethodsInfoMaster: CookingMethodsInfoMaster(cookingMethodsInfo: []),
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));
      state.liquidNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.liquidNames?.foodsAndDrinksNames?.foodNames?.removeWhere((f) => f.included == 1);
      state.liquidNames?.foodsAndDrinksNames?.drinkNames?.removeWhere((f) => f.included == 1);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetLiquidsInFavoriteAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null));

      state.liquidsInFavorite = event.liquidsInFavorite;
      emit(state.copyWith(isLoading: false,));
    });

    on<AddCommentToFavoriteActions>((event, emit) {
      state.comment = event.comment;

      event.onFinish.call();
      emit(state.copyWith(isLoading: false));
    });

    on<AddLiquidNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });


    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = LiquidFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.liquidsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
        comment: state.comment,
      );

      try {
        final uploadFavorite = await uploadLiquidFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveLiquidFavoriteInteractor.execute(foodFavorite);
            event.onFinish.call();
            emit(state.copyWith(isLoading: false));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveLiquidFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadLiquidFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadLiquidFavoriteError));
      }
    });
  }

}