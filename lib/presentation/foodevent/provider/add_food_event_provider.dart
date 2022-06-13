import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

// TODO: Tengo que poner lo de las bebidas.
class AddFoodEventProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;

  AddFoodEventProvider({
    required this.getUserIdInteractor,
    required this.saveFoodEventInteractor,
    required this.uploadFoodEventInteractor,
    required this.getMasterFileInteractor,
  });

  bool onSaveFoodEventSuccess = false;
  get isInfoLoaded => _infoLoaded;
  get getFoodAndDrinksNames => _foodAndDrinksNames;
  get getCookingMethods => _cookingMethods;
  get getCookingMethodsInfo => _cookingMethodsInfo;
  get getIngredients => _ingredients;
  get getDrinks => _drinks;

  bool _infoLoaded = false;
  FoodsAndDrinksNamesMaster? _foodAndDrinksNames;
  CookingMethodsMaster? _cookingMethods;
  CookingMethodsInfoMaster? _cookingMethodsInfo;
  final List<FoodInEvent> _ingredients = [];
  final List<FoodInEvent> _drinks = [];

  void initialize() {
    if (!isInfoLoaded) {
      _setInfoLoaded(true);
      getFoodAndDrinksNames.doIfNull(_retrieveFoodAndDrinks);
      getCookingMethods.doIfNull(_retrieveCookingMethods);
      getCookingMethodsInfo.doIfNull(_retrieveCookingMethodsInfo);
    }
  }

  void addIngredient(FoodInEvent foodEntered) {
    if (getIngredients.map((e) => e.id).contains(foodEntered.id)) {
      final editedEventIndex = getIngredients.firstWhere((element) => element.id == foodEntered.id);
      getIngredients.replaceRange(getIngredients.indexOf(editedEventIndex), getIngredients.indexOf(editedEventIndex)+1, [foodEntered]);
    } else {
      getIngredients.add(foodEntered);
    }
    notifyListeners();
  }

  void removeIngredient(FoodInEvent foodEntered) {
    getIngredients.remove(foodEntered);
    notifyListeners();
  }

  void addDrink(FoodInEvent drinkEntered) {
    if (getDrinks.map((e) => e.id).contains(drinkEntered.id)) {
      final editedEventIndex = getDrinks.firstWhere((element) => element.id == drinkEntered.id);
      getDrinks.replaceRange(getDrinks.indexOf(editedEventIndex), getDrinks.indexOf(editedEventIndex)+1, [drinkEntered]);
    } else {
      getDrinks.add(drinkEntered);
    }
    notifyListeners();
  }

  void removeDrink(FoodInEvent drinkEntered) {
    getDrinks.remove(drinkEntered);
    notifyListeners();
  }

  void onFinishClicked(Function onFinish) {
    final foodEvent = FoodEventSimple(
        userId: getUserIdInteractor.execute(),
        date: DateTime.now().millisecondsSinceEpoch
    );
    foodEvent.ingredients = getIngredients;
    foodEvent.drinks = getDrinks;

    launchSync(
      block: () => uploadFoodEventInteractor.execute(foodEvent),
      onSuccess: (UploadFoodEvent uploadFoodEvent) {
        if (uploadFoodEvent.uploadSuccess) {
          launchSync(
            block: () => saveFoodEventInteractor.execute(uploadFoodEvent),
            onSuccess: (_) {
              onSaveFoodEventSuccess = true;
              notifyListeners();
              Future.delayed(const Duration(milliseconds: 1000), () {
                onSaveFoodEventSuccess = false;
                getIngredients.clear();
                getDrinks.clear();
                notifyListeners();
                onFinish.call();
              });
            },
            onError: (error) {
              // TODO: manage error.
              final h = error;
            }
          );
        } else {
          // TODO: manage error uploading even
        }
      },
      onError: (Object error) {
        // TODO: manage error uploading even
        final g = error.toString();
        },
    );
  }

  bool _setInfoLoaded(bool infoLoaded) => _infoLoaded = infoLoaded;
  void _setFoodAndDrinksNames(FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) => _foodAndDrinksNames = foodsAndDrinksNamesMaster;
  void _setCookingMethods(CookingMethodsMaster cookingMethodsMaster) => _cookingMethods = cookingMethodsMaster;
  void _setCookingMethodsInfo(CookingMethodsInfoMaster cookingMethodsInfoMaster) => _cookingMethodsInfo = cookingMethodsInfoMaster;

  void _retrieveFoodAndDrinks() async {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames),
        onSuccess: (FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) => _setFoodAndDrinksNames(foodsAndDrinksNamesMaster),
        onError: (Object error) {
          // TODO: control error.
          const g = '';
          _setInfoLoaded(false);
        }
    );
  }

  void _retrieveCookingMethods() async {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.cookingMethods),
        onSuccess: (CookingMethodsMaster cookingMethodsMaster) => _setCookingMethods(cookingMethodsMaster),
        onError: (Object error) {
          // TODO: control error.
          _setInfoLoaded(false);
        }
    );
  }

  void _retrieveCookingMethodsInfo() async {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo),
        onSuccess: (CookingMethodsInfoMaster cookingMethodsInfo) => _setCookingMethodsInfo(cookingMethodsInfo),
        onError: (Object error) {
          _setInfoLoaded(false);
        }
    );
  }

}