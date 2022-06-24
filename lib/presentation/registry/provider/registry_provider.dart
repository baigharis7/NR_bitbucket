import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/activity_by_occupation_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/allergens.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/common_diseases.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/intolerances.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

class RegistryProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final UploadProfileInteractor uploadProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveUserRdasInteractor saveUserRdasInteractor;

  RegistryProvider({
    required this.getUserIdInteractor,
    required this.uploadProfileInteractor,
    required this.saveProfileInteractor,
    required this.getMasterFileInteractor,
    required this.saveUserRdasInteractor
  });

  bool get isInfoLoaded => _infoLoaded;
  List<ActivityByOccupationType> get listActivityTypes => ActivityByOccupationType.listAllActivityTypes();
  List<CommonDiseases> get listDiseases => CommonDiseases.listAllDiseases();
  List<Allergens> get listAllergens => Allergens.listAllAllergens();
  List<Intolerances> get listIntolerances => Intolerances.listAllIntolerances();
  List<DietType> get listDietTypes => DietType.listAllDietTypes();
  ObjectivesInfoMaster? get getObjectivesInfo => _objectivesInfoMaster;
  FoodsAndDrinksNamesMaster? get getFoodsAndDrinksNamesMaster => _foodsAndDrinksNamesMaster;
  String? get getCommonName => _commonName;
  get getBirthDate => _birthDate;
  get getSex => _sex;
  get getDiseases => _diseases;
  get isUnderTreatment => _underPharmaceuticalTreatment;
  get getHeight => _height;
  get getWeight => _weight;
  get getBodyFat => _bodyFat;
  get getWaistMeasurement => _waistMeasurement;
  get getActivityType => _activityType;
  get getPeriodRegularity => _periodRegularity;
  get getPeriodDuration => _periodDuration;
  get getLastPeriodDate => _lastPeriodDate;
  get getEatGuts => _eatGuts;
  get getIntolerances => _intolerances;
  get getDietType => _dietType;
  get getAllergens => _allergens;
  List<FoodItemMaster> get getAversions => _aversions ;
  get getObjectives => _objectives;

  bool _infoLoaded = false;
  String? _commonName;
  DateTime? _birthDate;
  double? _activityType;
  SexType? _sex;
  final List<int> _diseases = [];
  bool _underPharmaceuticalTreatment = false;
  int _height = Constants.HEIGHT_INITIAL_VALUE;
  bool _heightChosen = false;
  int _weight = Constants.WEIGHT_INITIAL_VALUE;
  bool _weightChosen = false;
  int _bodyFat = Constants.BODY_FAT_INITIAL_VALUE;
  bool _bodyFatChosen = false;
  int _waistMeasurement = Constants.WAIST_MEASUREMENT_INITIAL_VALUE;
  bool _waistMeasurementChosen = false;
  MenstruationRegularity? _periodRegularity;
  int _periodDuration = Constants.PERIOD_DURATION_INITIAL_VALUE;
  bool _periodDurationChosen = false;
  DateTime? _lastPeriodDate;
  final List<int> _allergens = [];
  final List<int> _intolerances = [];
  int? _dietType;
  final List<FoodItemMaster> _aversions = [];
  final List<int> _objectives = [];
  bool _areDietQuestionsChecked = false;
  bool _eatGuts = false;
  ObjectivesInfoMaster? _objectivesInfoMaster;
  FoodsAndDrinksNamesMaster? _foodsAndDrinksNamesMaster;

  @override
  void initialize(Function onError) {
    super.initialize(onError);
    if (!isInfoLoaded) {
      _setInfoIsLoaded(true);
      getObjectivesInfo.doIfNull(_retrieveObjectivesInfoMaster);
      getFoodsAndDrinksNamesMaster.doIfNull(_retrieveFoodAndDrinks);
    }
  }

  void setCommonName(String commonName) {
    _commonName = commonName;
    notifyListeners();
  }
  void setBirthDate(DateTime birthDate) {
    _birthDate = birthDate;
    notifyListeners();
  }
  void setSex(SexType sex) {
    _sex = sex;
    notifyListeners();
  }
  void setPharmaceuticalTreatment(bool changeCheck) {
    _underPharmaceuticalTreatment = changeCheck;
    notifyListeners();
  }
  void setHeight(int height) {
    _height = height;
    _heightChosen = true;
    notifyListeners();
  }

  void setWeight(int weight) {
    _weight = weight;
    _weightChosen = true;
    notifyListeners();
  }
  void setBodyFat(int bodyFat) {
    _bodyFat = bodyFat;
    _bodyFatChosen = true;
    notifyListeners();
  }
  void setWaistMeasurement(int waistMeasurement) {
    _waistMeasurement = waistMeasurement;
    _waistMeasurementChosen = true;
    notifyListeners();
  }
  void setPeriodRegularity(MenstruationRegularity regularity) {
    _periodRegularity = regularity;
  }
  void setPeriodDuration(int duration) {
    _periodDurationChosen = true;
    _periodDuration = duration;
  }
  void setLastPeriodDate(DateTime date) {
    _lastPeriodDate = date;
  }
  void setEatGuts(bool eatGuts) {
    _eatGuts = eatGuts;
    notifyListeners();
  }

  void manageDiseases(int diseaseId) {
    _diseases.contains(diseaseId)
        ? _diseases.remove(diseaseId)
        : _diseases.add(diseaseId);
    notifyListeners();
  }

  List<SimpleItem> getObjectivesList(String currentLanguage) {
    return getObjectivesInfo!.objectives.map((objective) => SimpleItem(
      name: _chooseRightLanguage(currentLanguage, objective),
      id: objective.id,
    )).toList();
  }

  void onActivityTypeSelected(double activityTypeSelected) {
    _activityType = activityTypeSelected;
    notifyListeners();
  }

  void manageAllergen(int allergen) {
    _allergens.contains(allergen)
        ? _allergens.remove(allergen)
        : _allergens.add(allergen);
    notifyListeners();
  }

  void manageIntolerance(int intolerance) {
    _intolerances.contains(intolerance)
        ? _intolerances.remove(intolerance)
        : _intolerances.add(intolerance);
    notifyListeners();
  }

  void manageDietType(int diet) {
    _dietType = diet;
    notifyListeners();
  }

  void manageAversions(FoodItemMaster aversion) {
    _aversions.contains(aversion)
        ? _aversions.remove(aversion)
        : _aversions.add(aversion);
    notifyListeners();
  }

  void removeAversion(FoodItemMaster aversion) {
    _aversions.remove(aversion);
    notifyListeners();
  }

  void setDietQuestionsChecked() {
    _areDietQuestionsChecked = true;
    notifyListeners();
  }

  bool areGeneralQuestionsAnswered() {
    bool condition = _commonName.isNotEmptyOrNull() &&
        _birthDate != null &&
        _activityType != null &&
        _sex != null;
    return condition;
  }

  bool areHealthQuestionsAnswered() {
    return _heightChosen && _weightChosen;
  }

  bool areWomenQuestionsAnswered() {
    if (getSex == SexType.female) {
      if (_periodRegularity == MenstruationRegularity.irregular) {
        return true;
      } else if (_periodRegularity == MenstruationRegularity.regular &&
          _periodDurationChosen &&
          _lastPeriodDate != null) {
        return true;
      }
    }
    return false;
  }

  bool areDietQuestionsAnswered() => _areDietQuestionsChecked;

  bool areObjectivesSelected() => _objectives.isEmpty ? false : true;

  void manageObjectives(int objective) {
    _objectives.contains(objective)
        ? _objectives.remove(objective)
        : _objectives.add(objective);
    notifyListeners();
  }

  showFinishButton() {
    return (areGeneralQuestionsAnswered() &&
        areHealthQuestionsAnswered() &&
        areDietQuestionsAnswered() &&
        ((getSex == SexType.female && areWomenQuestionsAnswered()) ||
            getSex == SexType.male) &&
        areObjectivesSelected());
  }

  void finishRegistry({required Function nextScreen}) {
    FemaleCharacteristics? femaleCharacteristics;
    if (getSex == SexType.female) {
      FemaleCharacteristics(
          menstruation: Menstruation(
              regularity: _periodRegularity!.index,
              // TODO: estos dos pueden ir a null si regularity es irregular.
              daysOfCycle: _periodDuration,
              lastStartDate: _lastPeriodDate?.millisecondsSinceEpoch));
    } else {
      femaleCharacteristics = null;
    }

    UserProfileModel profile = UserProfileModel(
      userId: getUserIdInteractor.execute(),
      commonName: getCommonName.orEmpty(),
      birthDate: _birthDate!.millisecondsSinceEpoch,
      sex: getSex!,
      occupationActivityFactor: getActivityType!,
      physicalCharacteristics: PhysicalCharacteristics(
          height: getHeight,
          weight: getWeight,
          bodyFat: _bodyFatChosen ? getBodyFat : null,
          waistMeasurement:
              _waistMeasurementChosen ? getWaistMeasurement : null),
      femaleCharacteristics: femaleCharacteristics,
      medicalSituation: MedicalSituation(
        commonDiseases: getDiseases,
        otherDiseases: [], // Añadir a pantalla
        underPharmaceuticalTreatment: isUnderTreatment,
      ),
      foodAversions:
          getAversions.map((foodItemMaster) => foodItemMaster.id!).toList(),
      dietType: getDietType,
      exclusions: Exclusions(exclusions: _addDietTypesToAllergens()),
      intolerances: getIntolerances,
      // symptoms: , // Añadir cuando esté implementado
      guts: 0,
      objectives: getObjectives,
    );

    launchSync(
      block: () => uploadProfileInteractor.execute(profile),
      onSuccess: (UserProfileResponse userProfileResponse) async {
        if (userProfileResponse.uploadSuccess) {
          launchSync(
              block: () => saveUserRdasInteractor.execute(userProfileResponse.userRdas),
              onSuccess: (_) {
                profile.micronutrients = userProfileResponse.micronutrients;
                launchSync(
                    block: () => saveProfileInteractor.execute(profile),
                    onSuccess: (_) => nextScreen.call(),
                    onError: (_) => onError?.call(ErrorTypes.savingProfileError));
            },
            onError: (_) => onError?.call(ErrorTypes.savingRdasError)
          );
        } else {
          onError?.call(ErrorTypes.uploadingProfileError);
        }
      },
      onError: (Object error) => onError?.call(ErrorTypes.uploadingProfileError)
    );
  }

  String _chooseRightLanguage(String languageCode, ObjectiveInfoMaster objectiveInfoMaster) {
    String objectiveName = '';
    if (languageCode == 'es') {
      objectiveName = objectiveInfoMaster.es;
    } else {
      objectiveName = objectiveInfoMaster.en;
    }
    return objectiveName;
  }

  void _setInfoIsLoaded(bool infoIsLoaded) => _infoLoaded = infoIsLoaded;
  void _setObjectivesInfoMaster(ObjectivesInfoMaster objectivesInfoMaster) => _objectivesInfoMaster = objectivesInfoMaster;
  void _setFoodsAndDrinksNamesMaster(FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) => _foodsAndDrinksNamesMaster = foodsAndDrinksNamesMaster;
  void _retrieveObjectivesInfoMaster() {
    launchSync(
      block: () => getMasterFileInteractor.execute(MasterFilesType.objectivesInfo),
      onSuccess: (ObjectivesInfoMaster objectivesInfoMaster) {
        _setObjectivesInfoMaster(objectivesInfoMaster);
      },
      onError: (error) {
        _setInfoIsLoaded(false);
        onError?.call(ErrorTypes.retrievingMasterFileError);
      },
    );
  }
  void _retrieveFoodAndDrinks() async {
    launchSync(
      block: () => getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames),
      onSuccess: (FoodsAndDrinksNamesMaster foodsAndDrinksNamesMaster) {
        _setFoodsAndDrinksNamesMaster(foodsAndDrinksNamesMaster);
      },
      onError: (Object error) => onError?.call(ErrorTypes.retrievingMasterFileError)
    );
  }

  List<int> _addDietTypesToAllergens() {
    if (_dietType != null) _allergens.add(_dietType!);
    return _allergens;
  }

}
