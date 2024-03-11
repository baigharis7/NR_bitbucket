import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_actions.dart';

import '../../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../../domain/models/masterfiles/food_names_master.dart';
import '../../../../domain/models/recipes/recipes_master.dart';

part 'recipe_detail_event.dart';

part 'recipe_detail_state.dart';

class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final GetMasterFileInteractor getMasterFileInteractor;

  RecipeDetailBloc({
    required this.getMasterFileInteractor,
  }) : super(RecipeDetailState(isLoading: false)) {
    on<InitializationRecipeDetailEventAction>((event, emit) async {
      final foodAndDrinksMasterFile = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames) as FoodsAndDrinksNamesMaster;
      state.foodAndDrinksNames = foodAndDrinksMasterFile.foodsAndDrinksNames!.foodNames?..addAll(foodAndDrinksMasterFile.foodsAndDrinksNames!.drinkNames!.toList());
    });

    on<UpdateDateFromRecipeFavoriteScreen>((event, emit) {
        emit(state.copyWith(isLoading: true));
        state.uploadRecipeFavorite = event.uploadRecipeFavorite;
        emit(state.copyWith(isLoading: false));
      },
    );

    on<UpdateDataFromDiscoverScreenEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.uploadRecipeFavorite = UploadRecipeFavorite(userId: null, eventDate: null, itemRecipe: event.recipeMaster);
      emit(state.copyWith(isLoading: false));
    },);
  }

  FoodItemMaster getFoodNameByFoodId(int foodId) {
    return state.foodAndDrinksNames.orEmpty().firstWhere(
        (foodItemMaster) => foodItemMaster.id == foodId,
        orElse: () => FoodItemMaster.empty(),
    );
  }
}
