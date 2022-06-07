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

  bool _infoLoaded = false;
  Recommendation? _recommendation;
  bool _recommendationOrdered = false;
  RecommendationGroupsMaster? _recommendationGroups;
  FoodsAndDrinksNamesMaster? _foodAndDrinksNames;
  final List<int> _selectedFoodIds = [];
  final List<String> _selectedFoodNames = [];
  bool _multiSelection = false;

  bool get isInfoLoaded => _infoLoaded;
  Recommendation? get getRecommendation => _recommendation;
  bool get isRecommendationOrdered => _recommendationOrdered;
  RecommendationGroupsMaster? get getRecommendationGroups => _recommendationGroups;
  FoodsAndDrinksNamesMaster? get getFoodAndDrinksNames => _foodAndDrinksNames;
  List<int> get getSelectedFoodIds => _selectedFoodIds;
  List<String> get getSelectedFoodNames => _selectedFoodNames;
  bool get isMultiSelectionActive => _multiSelection;

  void setInfoLoaded(bool infoLoaded) => _infoLoaded = infoLoaded;
  void setRecommendation(Recommendation? recommendation) => _recommendation = recommendation;
  void setRecommendationOrdered(bool isRecommendationOrdered) => _recommendationOrdered = isRecommendationOrdered;
  void setRecommendationGroups(RecommendationGroupsMaster recommendationGroups) => _recommendationGroups = recommendationGroups;
  void setFoodsAndDrinksNames(FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) => _foodAndDrinksNames = foodsAndDrinksNamesMaster;
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

  void initialize() {
    if (!isInfoLoaded) {
      setInfoLoaded(true);
      launchSync(
        block: () {
          getRecommendationGroups.doIfNull(retrieveRecommendationGroups);
          getFoodAndDrinksNames.doIfNull(retrieveFoodAndDrinks);
          return true;
          },
          onSuccess: (_) => orderRecommendation()
      );
    }
  }

  void orderRecommendation() async {
    final _userId = getUserIdInteractor.execute();
    setRecommendationOrdered(true);
    launchSync(
      block: () => getRecommendationInteractor.execute(_userId.orEmpty()),
      onSuccess: (Recommendation? recommendation) {
        setRecommendation(recommendation!);
        notifyListeners();
        },
      onError: (Object error) {
        _recommendation = null;
        setRecommendationOrdered(false);
        notifyListeners();
        // TODO: manage errors.
        },
    );
  }

  void retrieveFoodAndDrinks() async {
    launchSync(
        showLoading: false,
        block: () => getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames),
        onSuccess: (FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) {
          setFoodsAndDrinksNames(foodsAndDrinksNamesMaster);
          notifyListeners();
        },
        onError: (Object error) {
          // TODO: control error.
          setInfoLoaded(false);
        }
    );
  }

  void retrieveRecommendationGroups() {
    launchSync(
      showLoading: false,
      block: () => getMasterFileInteractor.execute(MasterFilesType.recommendationGroups),
      onSuccess: (RecommendationGroupsMaster recommendationGroups) {
        setRecommendationGroups(recommendationGroups);
        notifyListeners();
      },
      onError: () {
        // TODO: manage errors.
        setInfoLoaded(false);
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

  Future<bool> removeRecommendation() async {
    setRecommendation(null);
    return true;
  }
}