import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';

part 'food_event.dart';

part 'food_state.dart';

class FoodBloc extends Bloc<FoodEventActions, FoodEventState> {
  final GetMasterFileInteractor getMasterFileInteractor;

  FoodBloc({required this.getMasterFileInteractor})
      : super(
          FoodEventState(
              foodNames: FoodsAndDrinksNamesMaster(
                FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
              ),
              filteredFood: []),
        ) {
    on<InitializeStateEventAction>((event, emit) async {
      if (state.foodNames!.foodsAndDrinksNames!.foodNames!.isEmpty) {
        state.foodNames = await getMasterFileInteractor
            .execute(MasterFilesType.foodsAndDrinksNames);
        state.foodNames?.foodsAndDrinksNames?.foodNames?.removeWhere((f) => f.included == 1);
        state.foodNames?.foodsAndDrinksNames?.drinkNames?.removeWhere((f) => f.included == 1);
      }
    });

    on<OnChangeEditTextStateAction>((event, emit) {
      List<FoodItemMaster> filteredFoodList = [];
      if (event.foodName.isNotEmpty) {
        filteredFoodList = state.foodNames!.foodsAndDrinksNames!.foodNames!
            .where(
              (element) => element.en
                  .toString()
                  .toLowerCase()
                  .contains(event.foodName.toLowerCase()),
            )
            .toList();
      }
      emit(state.copyWith(filteredFood: filteredFoodList));
    });
  }
}
