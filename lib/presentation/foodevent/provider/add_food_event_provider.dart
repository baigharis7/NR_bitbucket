import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';

import '../../../domain/interactor/foodevents/save_food_event_interactor.dart';
import '../../../domain/interactor/foodevents/upload_food_event_interactor.dart';
import '../../../domain/interactor/preferences/get_user_id_interactor.dart';
import '../../../domain/models/foodevents/food_event_simple.dart';
import '../../../domain/models/masterfiles/cooking_methods_info_master.dart';
import '../../../domain/models/masterfiles/cooking_methods_master.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../common/provider/base_provider.dart';

// TODO: Tengo que poner lo de las bebidas.
class AddFoodEventProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;

  AddFoodEventProvider({required this.getUserIdInteractor, required this.saveFoodEventInteractor, required this.uploadFoodEventInteractor,});

  FoodsAndDrinkListsMaster? _foodAndDrinksList;
  CookingMethodsMaster? _cookingMethods;
  CookingMethodsInfoMaster? _cookingMethodsInfo;
  final List<FoodInEvent> _ingredients = [];
  final List<FoodInEvent> _drinks = [];
  bool onSaveFoodEventSuccess = false;

  FoodsAndDrinkListsMaster? get getFoodAndDrinksList => _foodAndDrinksList;
  CookingMethodsMaster? get getCookingMethods => _cookingMethods;
  CookingMethodsInfoMaster? get getCookingMethodsInfo => _cookingMethodsInfo;
  List<FoodInEvent> get getIngredients => _ingredients;
  List<FoodInEvent> get getDrinks => _drinks;

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

  // TODO: esto hay que hacerlo con interactors y un repositorio. Cuando lo descargue de AWS.
  void retrieveCookingMethods(Future<Map<String, dynamic>> cookingMethods, {Function? nextCall}) async {
    launchSync(
        block: () async {
          final CookingMethodsMaster cookingMethodsMaster = CookingMethodsMaster.fromJson(await cookingMethods);
          return cookingMethodsMaster;
        },
        onSuccess: (cookingMethods) {
          _cookingMethods = cookingMethods;
          nextCall?.call();
        },
        onError: (Object error) {
          // TODO: control error.
        }
    );
  }

  void retrieveCookingMethodsInfo(Future<Map<String, dynamic>> cookingMethodsInfo, {Function? nextCall}) async {
    launchSync(
        block: () async {
          final CookingMethodsInfoMaster cookingMethodsInfoMaster = CookingMethodsInfoMaster.fromJson(await cookingMethodsInfo);
          return cookingMethodsInfoMaster;
        },
        onSuccess: (cookingMethodsInfo) {
          _cookingMethodsInfo = cookingMethodsInfo;
          nextCall?.call();
        },
        onError: (Object error) {
          // TODO: control error.
        }
    );
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
            block: () {
              saveFoodEventInteractor.execute(uploadFoodEvent);
            },
            onSuccess: (_) {
              onSaveFoodEventSuccess = true;
              notifyListeners();
              Future.delayed(const Duration(milliseconds: 1000), () {
                onSaveFoodEventSuccess = false;
                _ingredients.clear();
                _drinks.clear();
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
        final g = error.toString();
        },
    );
  }

}