import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recommendations/bloc/recommendations_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recommendations/bloc/recommendations_state.dart';

class RecommendationsBloc extends BaseBloc<RecommendationsActions, RecommendationsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetRecommendationInteractor getRecommendationInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  RecommendationsBloc({
    required this.getRecommendationInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(RecommendationsState(
    isLoading: false,
    recommendationFoodsItems: [],
    selectedFoodNames: [],
    selectedFoodIds: [],
    showCard: false,
  ),) {
    on<InitialStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, recommendationFoodsItems: [],));
      state.recommendationGroups = await getMasterFileInteractor.execute(MasterFilesType.recommendationGroups);
      state.foodAndDrinksNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);

      if (state.recommendationFoodsItems!.isEmpty) {
        try {
          final recommendation = await getRecommendationInteractor.execute(
              getUserIdInteractor.execute(),);
          state.recommendation = recommendation;
          // state.recommendationFoodsItems = state.recommendation!.foodList
          //     .map((groupRecommendation) =>
          //     RecommendationsFoodItem(
          //       foodGroupName: findRecommendationGroupName(
          //           groupRecommendation.recGroup,),
          //       recommendedFoods: getRecommendationFoodInfo(
          //           groupRecommendation.foods,),
          //       frequentFoods: getRecommendationFoodInfo(
          //           groupRecommendation.usualFoods,),
          //     ),).toList();
          state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recommendations.index);
          emit(state.copyWith(isLoading: false));
        } catch (error) {
          state.recommendation = null;
          state.onError = ErrorTypes.recommendationError;
          emit(state.copyWith(isLoading: false,));
        }
      }
    });

    on<EmptyRecommendationAction>((event, emit) {
      emit(state.copyWith(isLoading: false, recommendationFoodsItems: []));
    });

    on<ManageFoodToListAction>((event, emit) {
      state.selectedFoodIds!.contains(event.id) ? state.selectedFoodIds!.remove(event.id) : state.selectedFoodIds!.add(event.id);

      emit(state.copyWith(isLoading: false,));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.recommendations.index);

      emit(state.copyWith(isLoading: false,));
    });
  }

  RecommendationGroup findRecommendationGroupName(int groupId) {
    return state.recommendationGroups!.recommendationGroups.firstWhere((recommendationGroup) => recommendationGroup.id == groupId);
  }

  String findFoodName(int foodId, BuildContext context) {
    FoodItemMaster foodItemMaster = state.foodAndDrinksNames!.foodsAndDrinksNames!.foodNames!.firstWhere((food) => food.id == foodId, orElse: () => FoodItemMaster());
    if (foodItemMaster.translate(context) == '') {
      foodItemMaster = state.foodAndDrinksNames!.foodsAndDrinksNames!.drinkNames!.firstWhere((food) => food.id == foodId, orElse: () => FoodItemMaster());
    }
    return foodItemMaster.translate(context);
  }

  // List<RecommendationFoodInfo> getRecommendationFoodInfo(List<int> foodList, BuildContext context) {
  //   final list = foodList.map((foodId) => RecommendationFoodInfo(
  //     id: foodId,
  //     foodName: findFoodName(foodId, context),
  //     foodNutrients: /** DUMMY, must receive from backend */[],
  //   ),).toList();
  //
  //   list.removeWhere((foodInfo) => foodInfo.foodName == '');
  //
  //   return list;
  // }

}