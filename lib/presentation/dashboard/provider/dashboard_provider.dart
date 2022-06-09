import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_all_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_objective_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

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

  List<FoodEventComplete> _foodEvents = [];
  bool _infoLoaded = false;
  NutrientsObjectiveMaster? _nutrientsObjective;
  List<String> _userMicronutrients = [];
  NutrientsInfoMaster? _nutrientsInfoMaster;
  List<UserRdas>? _userRdas;

  List<FoodEventComplete> get getFoodEvents => _foodEvents;
  bool get isInfoLoaded => _infoLoaded;
  NutrientsObjectiveMaster? get getNutrientsObjective => _nutrientsObjective;
  List<String> get getUserMicronutrients => _userMicronutrients;
  NutrientsInfoMaster? get getNutrientsInfoMaster => _nutrientsInfoMaster;
  List<UserRdas>? get getUserRdas => _userRdas;

  void setFoodEvents(List<FoodEventComplete> foodEvents) => _foodEvents = foodEvents;
  void setInfoLoaded(bool foodEventsLoaded) => _infoLoaded = foodEventsLoaded;
  void setNutrientsObjective(NutrientsObjectiveMaster nutrientsObjective) => _nutrientsObjective = nutrientsObjective;
  void setUserMicronutrients(List<String> micronutrients) => _userMicronutrients = micronutrients;
  void setNutrientsInfoMaster(NutrientsInfoMaster nutrientsInfoMaster) => _nutrientsInfoMaster = nutrientsInfoMaster;
  void setUserRdas(List<UserRdas> userRdas) => _userRdas = userRdas;

  void initialize(Future<Map<String, dynamic>> nutrientsObjective) {
    if (!isInfoLoaded) {
      setInfoLoaded(true);
      getFoodEvents.isEmpty.doIfTrue(retrieveFoodEvents);
      getNutrientsObjective.doIfNull(() => retrieveNutrientsObjectives(nutrientsObjective));
      getNutrientsInfoMaster.doIfNull(retrieveNutrientsInfoFile);
      getUserRdas.doIfNull(retrieveUserRdas);
    }
  }

  void retrieveFoodEvents() {
    launchSync(
        block: () => getAllFoodEventsInteractor.execute(),
        onSuccess: (List<FoodEventComplete> foodEvents) {
          setFoodEvents(foodEvents);
          notifyListeners();
        },
        onError: (Object error) {
          // TODO: manage errors.
          const g = '';
          setInfoLoaded(false);
        }
    );
  }

  void retrieveNutrientsObjectives(Future<Map<String, dynamic>> nutrientsObjective) async {
    launchSync(
        block: () async {
          final t = await nutrientsObjective;
          final NutrientsObjectiveMaster nutrientsObjectiveMaster = NutrientsObjectiveMaster.fromJson(t);
          return nutrientsObjectiveMaster;
        },
        onSuccess: (NutrientsObjectiveMaster nutrientsObjective) {
          setNutrientsObjective(nutrientsObjective);
        },
        onError: (Object error) {
          // TODO: control error.
          const g = '';
          setInfoLoaded(false);
        }
    );
  }

  void retrieveNutrientsInfoFile() {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo),
        onSuccess: (NutrientsInfoMaster nutrientsInfoMaster) {
          setNutrientsInfoMaster(nutrientsInfoMaster);
          retrieveUserMicronutrients();
        },
        onError: (error) {
          // TODO: manage errors.
          setInfoLoaded(false);
        });
  }

  void retrieveUserMicronutrients() {
    launchSync(
        block: () => getUserMicronutrientsInteractor.execute(),
        onSuccess: (List<String> userMicronutrients) {
          setUserMicronutrients(userMicronutrients);
          notifyListeners();
        },
        onError: (error) {
          // TODO: manage error.
          const g = '';
        }
    );
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
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = nutrientQuantitySoFar/rdaForUser;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  void retrieveUserRdas() {
    launchSync(
        block: () => getUserRdasInteractor.execute(),
        onSuccess: (List<UserRdas> userRdas) {
          setUserRdas(userRdas);
        },
        onError: (error) {
          // TODO: manage errors.
          const g = '';
          setInfoLoaded(false);
        },
    );
  }

}