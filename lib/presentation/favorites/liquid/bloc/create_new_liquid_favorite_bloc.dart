import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/save_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/upload_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_state.dart';

class CreateNewLiquidFavoriteBloc extends BaseBloc<CreateNewLiquidFavoriteActions, CreateNewLiquidFavoriteState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveLiquidFavoriteInteractor saveLiquidFavoriteInteractor;
  final UploadLiquidFavoriteInteractor uploadLiquidFavoriteInteractor;

  CreateNewLiquidFavoriteBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.saveLiquidFavoriteInteractor,
    required this.uploadLiquidFavoriteInteractor,
  }) : super(CreateNewLiquidFavoriteState(isLoading: false)) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.liquidNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.liquidNames?.foodsAndDrinksNames?.foodNames?.removeWhere((f) => f.included == 1);
      state.liquidNames?.foodsAndDrinksNames?.drinkNames?.removeWhere((f) => f.included == 1);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.unitsLiquidsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.liquidsInFavorite = [];

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<RemoveLiquidFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      state.liquidsInFavorite!.remove(event.liquidInFavorite);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddLiquidFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      if (state.liquidsInFavorite!.map((liquid) => liquid.id).contains((event.liquidInFavorite).id)) {
        final itemIndex = state.liquidsInFavorite!.indexOf(state.liquidsInFavorite!.firstWhere((liquid) => liquid.id == event.liquidInFavorite.id));
        state.liquidsInFavorite!.remove(state.liquidsInFavorite![itemIndex]);
        state.liquidsInFavorite!.add(event.liquidInFavorite);
      } else {
        state.liquidsInFavorite!.add(event.liquidInFavorite);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SelectCookingMethodAction>((event, emit){
      state.liquidsInFavorite!.add(event.liquidInFavorite);
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddLiquidNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishLiquidFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final liquidFavorite = LiquidFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.liquidsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
      );

      try {
        final uploadFavorite = await uploadLiquidFavoriteInteractor.execute(liquidFavorite);
        if (uploadFavorite) {
          try {
            await saveLiquidFavoriteInteractor.execute(liquidFavorite);
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

      event.onFinish.call();
      emit(state.copyWith(isLoading: false,));
    });
  }

}