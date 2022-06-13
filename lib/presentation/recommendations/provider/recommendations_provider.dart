import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

class RecommendationsProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final GetRecommendationInteractor getRecommendationInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;

  RecommendationsProvider({
    required this.getRecommendationInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor
  });

  get isInfoLoaded => _infoLoaded;
  get getRecommendation => _recommendation;
  get isRecommendationOrdered => _recommendationOrdered;
  get getRecommendationGroups => _recommendationGroups;
  get getFoodAndDrinksNames => _foodAndDrinksNames;
  get getSelectedFoodIds => _selectedFoodIds;
  get getSelectedFoodNames => _selectedFoodNames;
  get isMultiSelectionActive => _multiSelection;

  bool _infoLoaded = false;
  Recommendation? _recommendation;
  bool _recommendationOrdered = false;
  RecommendationGroupsMaster? _recommendationGroups;
  FoodsAndDrinksNamesMaster? _foodAndDrinksNames;
  final List<int> _selectedFoodIds = [];
  final List<String> _selectedFoodNames = [];
  bool _multiSelection = false;

  void initialize() {
    if (!isInfoLoaded) {
      _setInfoLoaded(true);
      launchSync(
          block: () {
            getRecommendationGroups.doIfNull(_retrieveRecommendationGroups);
            getFoodAndDrinksNames.doIfNull(_retrieveFoodAndDrinks);
            return true;
          },
          onSuccess: (_) => _orderRecommendation()
      );
    }
  }

  void manageSelectedFood(SimpleItem foodId) {
    getSelectedFoodIds.contains(foodId.id) ? getSelectedFoodIds.remove(foodId.id) : getSelectedFoodIds.add(foodId.id);
    getSelectedFoodNames.contains(foodId.name) ? getSelectedFoodNames.remove(foodId.name) : getSelectedFoodNames.add(foodId.name);
    if (getSelectedFoodIds.isEmpty) setMultiSelection(false);
    notifyListeners();
  }

  void setMultiSelection(bool isActive) {
    _multiSelection = isActive;
    notifyListeners();
  }

  String getRecommendationGroupName(int groupRecommendation, String language) {
    final recommendationGroup = getRecommendationGroups!.recommendationGroups.firstWhere((recommendationGroups) => recommendationGroups.id == groupRecommendation);
    if (language == 'es') {
      return recommendationGroup.es;
    } else {
      return recommendationGroup.en;
    }
  }

  List<SimpleItem> getRecommendedFoodNames(List<int> foodIds, String language) {
    final foodAndDrinkNames = [...getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames!, ...getFoodAndDrinksNames!.foodsAndDrinksNames!.drinkNames!];
    return foodIds.map((id) {
      final foodItem = foodAndDrinkNames.firstWhere((foodName) => foodName.id == id);
      if (language == 'es') {
        return SimpleItem(name: foodItem.es.orEmpty().toString(), id: id);
      } else {
        return SimpleItem(name: foodItem.en.orEmpty().toString(), id: id);

      }
    }).toList();
  }

  void _setInfoLoaded(bool infoLoaded) => _infoLoaded = infoLoaded;
  void _setRecommendation(Recommendation? recommendation) => _recommendation = recommendation;
  void _setRecommendationOrdered(bool isRecommendationOrdered) => _recommendationOrdered = isRecommendationOrdered;
  void _setRecommendationGroups(RecommendationGroupsMaster recommendationGroups) => _recommendationGroups = recommendationGroups;
  void _setFoodsAndDrinksNames(FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) => _foodAndDrinksNames = foodsAndDrinksNamesMaster;

  void _orderRecommendation() async {
    final _userId = getUserIdInteractor.execute();
    _setRecommendationOrdered(true);
    launchSync(
      block: () => getRecommendationInteractor.execute(_userId.orEmpty()),
      onSuccess: (Recommendation? recommendation) {
        _setRecommendation(recommendation!);
        notifyListeners();
      },
      onError: (Object error) {
        _recommendation = null;
        _setRecommendationOrdered(false);
        notifyListeners();
        // TODO: manage errors.
      },
    );
  }

  void _retrieveFoodAndDrinks() async {
    launchSync(
        showLoading: false,
        block: () => getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames),
        onSuccess: (FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) {
          _setFoodsAndDrinksNames(foodsAndDrinksNamesMaster);
          notifyListeners();
        },
        onError: (Object error) {
          // TODO: control error.
          _setInfoLoaded(false);
        }
    );
  }

  void _retrieveRecommendationGroups() {
    launchSync(
      showLoading: false,
      block: () => getMasterFileInteractor.execute(MasterFilesType.recommendationGroups),
      onSuccess: (RecommendationGroupsMaster recommendationGroups) {
        _setRecommendationGroups(recommendationGroups);
        notifyListeners();
      },
      onError: () {
        // TODO: manage errors.
        _setInfoLoaded(false);
      },
    );
  }

}