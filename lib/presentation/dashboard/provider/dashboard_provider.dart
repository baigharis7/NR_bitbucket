import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

class DashboardProvider extends BaseProvider {
  final GetAllFoodEventsInteractor getAllFoodEventsInteractor;
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserRdasInteractor getUserRdasInteractor;

  DashboardProvider({
    required this.getAllFoodEventsInteractor,
    required this.getUserMicronutrientsInteractor,
    required this.getMasterFileInteractor,
    required this.getUserRdasInteractor,
  });

  get getFoodEvents => _foodEvents;
  get isInfoLoaded => _infoLoaded;
  get getUserMicronutrients => _userMicronutrients;
  get getNutrientsInfoMaster => _nutrientsInfoMaster;
  get getUserRdas => _userRdas;

  List<FoodEventComplete> _foodEvents = [];
  bool _infoLoaded = false;
  List<String> _userMicronutrients = [];
  NutrientsInfoMaster? _nutrientsInfoMaster;
  List<UserRdas>? _userRdas;

  void initialize() {
    if (!isInfoLoaded) {
      _setInfoLoaded(true);
      getFoodEvents.isEmpty.doIfTrue(_retrieveFoodEvents);
      getNutrientsInfoMaster.doIfNull(_retrieveNutrientsInfoFile);
      getUserRdas.doIfNull(_retrieveUserRdas);
    }
  }

  // TODO: darle una vuelta a esta función, probablemente sea más eficiente generando un array con los nombres de los mN.
  String getNutrientName(String nutrientName, String currentLanguage) {
    final nutrientInfo = getNutrientsInfoMaster!.nutrientsInfo.firstWhere((info) => info.officialName == nutrientName);
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

  // TODO: restringir la información que sale a sólo los eventos del día. Hacer filtrado en la parte del repositorio.
  double getFractionToFill(String micronutrient) {
    final rdaForUser = getUserRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in getFoodEvents) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar + (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = nutrientQuantitySoFar/rdaForUser;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  void _setFoodEvents(List<FoodEventComplete> foodEvents) => _foodEvents = foodEvents;
  void _setInfoLoaded(bool foodEventsLoaded) => _infoLoaded = foodEventsLoaded;
  void _setUserMicronutrients(List<String> micronutrients) => _userMicronutrients = micronutrients;
  void _setNutrientsInfoMaster(NutrientsInfoMaster nutrientsInfoMaster) => _nutrientsInfoMaster = nutrientsInfoMaster;
  void _setUserRdas(List<UserRdas> userRdas) => _userRdas = userRdas;

  void _retrieveFoodEvents() {
    launchSync(
        block: () => getAllFoodEventsInteractor.execute(),
        onSuccess: (List<FoodEventComplete> foodEvents) {
          _setFoodEvents(foodEvents);
          notifyListeners();
        },
        onError: (Object error) {
          // TODO: manage errors.
          const g = '';
          _setInfoLoaded(false);
        }
    );
  }

  void _retrieveNutrientsInfoFile() {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo),
        onSuccess: (NutrientsInfoMaster nutrientsInfoMaster) {
          _setNutrientsInfoMaster(nutrientsInfoMaster);
          _retrieveUserMicronutrients();
        },
        onError: (error) {
          // TODO: manage errors.
          _setInfoLoaded(false);
        });
  }

  void _retrieveUserMicronutrients() {
    launchSync(
        block: () => getUserMicronutrientsInteractor.execute(),
        onSuccess: (List<String> userMicronutrients) {
          _setUserMicronutrients(userMicronutrients);
          notifyListeners();
        },
        onError: (error) {
          // TODO: manage error.
          const g = '';
        }
    );
  }

  void _retrieveUserRdas() {
    launchSync(
      block: () => getUserRdasInteractor.execute(),
      onSuccess: (List<UserRdas> userRdas) => _setUserRdas(userRdas),
      onError: (error) {
        // TODO: manage errors.
        const g = '';
        _setInfoLoaded(false);
      },
    );
  }

}