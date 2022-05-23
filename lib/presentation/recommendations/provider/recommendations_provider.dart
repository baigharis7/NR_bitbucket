import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

class RecommendationsProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final GetRecommendationInteractor getRecommendationInteractor;

  RecommendationsProvider({required this.getRecommendationInteractor, required this.getUserIdInteractor});

  Recommendation? _recommendation;
  bool _recommendationOrdered = false;
  RecommendationGroupsMaster? _recommendationGroups;
  FoodsAndDrinkListsMaster? _foodAndDrinksList;
  final List<int> _selectedFoodIds = [];
  final List<String> _selectedFoodNames = [];
  bool _multiSelection = false;

  FoodsAndDrinkListsMaster? get getFoodAndDrinksList => _foodAndDrinksList;
  Recommendation? get getRecommendation => _recommendation;
  bool get isRecommendationOrdered => _recommendationOrdered;
  RecommendationGroupsMaster? get getRecommendationGroups => _recommendationGroups;
  List<int> get getSelectedFoodIds => _selectedFoodIds;
  List<String> get getSelectedFoodNames => _selectedFoodNames;
  bool get isMultiSelectionActive => _multiSelection;

  void setRecommendationOrdered(bool isRecommendationOrdered) => _recommendationOrdered = isRecommendationOrdered;
  void setRecommendation(Recommendation recommendation) => _recommendation = recommendation;
  void setRecommendationGroups(RecommendationGroupsMaster recommendationGroups) => _recommendationGroups = recommendationGroups;
  void manageSelectedFood(Map<String, dynamic> foodId) {
    getSelectedFoodIds.contains(foodId['id']) ? getSelectedFoodIds.remove(foodId['id']) : getSelectedFoodIds.add(foodId['id']);
    getSelectedFoodNames.contains(foodId['foodName']) ? getSelectedFoodNames.remove(foodId['foodName']) : getSelectedFoodNames.add(foodId['foodName']);
    if (getSelectedFoodIds.isEmpty) setMultiSelection(false);
    notifyListeners();
  }
  void setMultiSelection(bool isActive) {
    _multiSelection = isActive;
    notifyListeners();
  }

  void orderRecommendation(Future<Map<String, dynamic>> recommendationGroups,
      {Function? onSuccess}) async {
    final _userId = getUserIdInteractor.execute();
    setRecommendationOrdered(true);
    launchSync(
      block: () => getRecommendationInteractor.execute(_userId.orEmpty()),
      onSuccess: (Recommendation? recommendation) {
        setRecommendation(recommendation!);
        if (_recommendationGroups == null) {
          retrieveRecommendationGroups(recommendationGroups, onSuccess);
        } else {
          notifyListeners();
        }
        },
      onError: (Object error) {
        _recommendation = null;
        setRecommendationOrdered(false);
        notifyListeners();
        },
    );
  }

  void retrieveFoodAndDrinks(Future<Map<String, dynamic>> foodMap, {Function? nextCall}) async {
    launchSync(
        block: () async {
          final FoodAndDrinksNamesMaster foodNames = FoodAndDrinksNamesMaster.fromJson(await foodMap);
          return foodNames.foodAndDrinksNames!.data;
        },
        onSuccess: (foodAndDrinksList) {
          _foodAndDrinksList = foodAndDrinksList;
          nextCall?.call();
        },
        onError: (Object error) {
          // TODO: control error.
        }
    );
  }

  void retrieveRecommendationGroups(Future<Map<String, dynamic>> recommendationGroups, Function? onSuccess) {
    launchSync(
      block: () async {
        final RecommendationGroupsMaster recommendationGroupsMaster = RecommendationGroupsMaster.fromJson(await recommendationGroups);
        return recommendationGroupsMaster;
      },
      onSuccess: (RecommendationGroupsMaster recommendationGroups) {
        setRecommendationGroups(recommendationGroups);
        onSuccess?.call();
        notifyListeners();
      },
      onError: () {
        // TODO: manage errors.
      },
    );
  }

  String getRecommendationGroupName(int groupRecommendation, String language) {
    final recommendationGroup = getRecommendationGroups!.recommendationGroups.firstWhere((recommendationGroups) => recommendationGroups.id == groupRecommendation);
    if (language == 'es') {
      return recommendationGroup.es;
    } else {
      return recommendationGroup.en;
    }
  }

  List<Map<String, dynamic>> getRecommendedFoodNames(List<int> foodIds, String language) {
    final foodAndDrinkNames = [...getFoodAndDrinksList!.foodNames!, ...getFoodAndDrinksList!.drinkNames!];
    return foodIds.map((id) {
      final foodItem = foodAndDrinkNames.firstWhere((foodName) => foodName.id == id);
      if (language == 'es') {
        return {"id": id, "foodName": foodItem.es.orEmpty().toString()};
      } else {
        return {"id": id, "foodName": foodItem.en.orEmpty().toString()};

      }
    }).toList();
  }

}