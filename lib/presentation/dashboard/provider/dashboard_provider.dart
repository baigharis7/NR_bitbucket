import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_objective.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class DashboardProvider extends BaseProvider {
  final GetAllFoodEventsInteractor getAllFoodEventsInteractor;
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor;

  DashboardProvider({required this.getAllFoodEventsInteractor, required this.getUserMicronutrientsInteractor});

  List<FoodEventComplete> _foodEvents = [];
  NutrientsObjective? _nutrientsObjective;
  List<String> _userMicronutrients = [];
  NutrientsInfoMaster? _nutrientsInfoMaster;

  List<FoodEventComplete> get getFoodEvents => _foodEvents;
  NutrientsObjective? get getNutrientsObjective => _nutrientsObjective;
  List<String> get getUserMicronutrients => _userMicronutrients;
  NutrientsInfoMaster? get getNutrientsInfoMaster => _nutrientsInfoMaster;

  void setFoodEvents(List<FoodEventComplete> foodEvents) => _foodEvents = foodEvents;
  void setNutrientsObjective(NutrientsObjective nutrientsObjective) => _nutrientsObjective = nutrientsObjective;
  void setUserMicronutrients(List<String> micronutrients) => _userMicronutrients = micronutrients;
  void setNutrientsInfoMaster(NutrientsInfoMaster nutrientsInfoMaster) => _nutrientsInfoMaster = nutrientsInfoMaster;

  void retrieveFoodEvents({Function? nextCall}) {
    if (getFoodEvents.isEmpty) {
      launchSync(
          block: () => getAllFoodEventsInteractor.execute(),
          onSuccess: (List<FoodEventComplete> foodEvents) {
            setFoodEvents(foodEvents);
            nextCall?.call();
            notifyListeners();
          },
          onError: (Object error) {
            // TODO: manage errors.
            const g = '';
          }
      );
    }
  }

  void retrieveNutrientsObjectives(Future<Map<String, dynamic>> nutrientsObjective, {Function? nextCall}) async {
    launchSync(
        block: () async {
          final t = await nutrientsObjective;
          final NutrientsObjective nutrientsObjectiveMaster = NutrientsObjective.fromJson(t);
          return nutrientsObjectiveMaster;
        },
        onSuccess: (NutrientsObjective nutrientsObjective) {
          setNutrientsObjective(nutrientsObjective);
          nextCall?.call();
        },
        onError: (Object error) {
          // TODO: control error.
          const g = '';
        }
    );
  }

  void retrieveNutrientsInfoFile(Future<Map<String, dynamic>> nutrientsInfo) {
    launchSync(
        block: () async {
          final NutrientsInfoMaster nutrientsInfoMaster = NutrientsInfoMaster.fromJson(await nutrientsInfo);
          return nutrientsInfoMaster;
        },
        onSuccess: (NutrientsInfoMaster nutrientsInfoMaster) {
          setNutrientsInfoMaster(nutrientsInfoMaster);
          retrieveUserMicronutrients();
        },
        onError: () {});
  }

  void retrieveUserMicronutrients() {
    launchSync(
        block: () => getUserMicronutrientsInteractor.execute(),
        onSuccess: (List<String> userMicronutrients) {
          setUserMicronutrients(userMicronutrients);
          notifyListeners();
        },
        onError: () {
          // TODO: manage error.
          const g = '';
        }
    );
  }

  // TODO: darle una vuelta a esta función, probablemente sea más eficiente generando un array con los nombres de los mN.
  String getNutrientName(String nutrientName, String currentLanguage) {

    final nutrientInfo = getNutrientsInfoMaster!.data.firstWhere((info) => info.officialName == nutrientName);
    if (currentLanguage == 'es') {
      String name = nutrientInfo.es.orEmpty();
      if (name.contains(",")) name = name.split(",")[0];
      return name;
    } else {
      String name = nutrientInfo.en.orEmpty();
      if (name.contains(",")) name = name.split(",")[0];
      return name;
    }
  }

  // TODO: ahora lo hago para Susana mañana, pero esto tiene que coger los valores de RDA para cada usuario según sus características.
  // TODO: restringir la información que sale a sólo los eventos del día. Hacer filtrado en la parte del repositorio.
  double getFractionToFill(String micronutrient) {
    final rdaForUser = getNutrientsObjective!.nutrients!.firstWhere((nutrient) => nutrient.name == micronutrient).female2 ?? 1.5;
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in getFoodEvents) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = nutrientQuantitySoFar/rdaForUser;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

}