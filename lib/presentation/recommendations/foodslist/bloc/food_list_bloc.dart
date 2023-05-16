import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/foodslist/bloc/food_list_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/foodslist/bloc/food_list_state.dart';

class FoodListBloc extends BaseBloc<FoodListActions, FoodListState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  FoodListBloc({
    required this.getMasterFileInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(FoodListState(
    isLoading: false,
    foodIdsList: [],
    foodNamesList: [],
    foodNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])),
    showCard: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.foodList.index);

      emit(state.copyWith(isLoading: false));
    });

    on<SetFoodIdsActions>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.foodIdsList = event.foodIds;
      final foodNames = state.foodIdsList!.map((foodId) {
        final foodName = state.foodNames!.foodsAndDrinksNames!.foodNames!.firstWhere((foodItemMaster) => foodItemMaster.id == foodId).translate(event.context);
        return SimpleItem(name: foodName, id: foodId);
      });
      state.foodNamesList = foodNames.toList();
      emit(state.copyWith(isLoading: false));
    });

    on<OnDeleteFoodIdFromList>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.foodIdsList!.remove(event.foodItem.id);
      state.foodNamesList!.remove(event.foodItem);

      emit(state.copyWith(isLoading: false));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.foodList.index);

      emit(state.copyWith(isLoading: false));
    });
  }

}