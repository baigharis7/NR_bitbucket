import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart' as upload;
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart' as entity;
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart' as domain;
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

upload.UploadUserProfile mapToUploadUserProfileModel(domain.UserProfileModel userProfileModel) {
  final upload.PhysicalCharacteristics physicalCharacteristics = upload.PhysicalCharacteristics(
    height: userProfileModel.physicalCharacteristics!.height!,
    weight: userProfileModel.physicalCharacteristics!.weight!,
    unit: userProfileModel.physicalCharacteristics?.unit,
    bodyFat: userProfileModel.physicalCharacteristics!.bodyFat,
    waistMeasurement: userProfileModel.physicalCharacteristics!.waistMeasurement,
  );

  final upload.FemaleCharacteristics? femaleCharacteristics = userProfileModel.sex!.index == upload.SexType.male.index
      ? null
      : upload.FemaleCharacteristics(
      menstruation: upload.Menstruation(
      regularity: userProfileModel.femaleCharacteristics?.menstruation?.regularity ?? 0,
      daysOfCycle: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 0
          ? userProfileModel.femaleCharacteristics?.menstruation?.daysOfCycle
          : null,
      lastStartDate: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 0
          ? userProfileModel.femaleCharacteristics?.menstruation?.lastStartDate
          : null,
    ),
  );

  final upload.MedicalSituation? medicalSituation = upload.MedicalSituation(
    commonDiseases: userProfileModel.medicalSituation!.commonDiseases!.convertToBinary(Constants.DISEASES_SIZE),
    otherDiseases: userProfileModel.medicalSituation!.otherDiseases,
    underPharmaceuticalTreatment: userProfileModel.medicalSituation!.underPharmaceuticalTreatment,
  );

  final String exclusions = _setExclusions(
      allergens: userProfileModel.exclusions!.exclusions.orEmpty(),
      dietType: userProfileModel.dietType,
  );

  final upload.UserRdas uploadUserRdas = upload.UserRdas(
    userRdas: userProfileModel.userRdas.isNull() ? [] : userProfileModel.userRdas!.userRdas.map((userRdas) => upload.UserRda(n: userRdas.name, rda: userRdas.rda, ul: userRdas.ul)).toList(),
  );

  final profile = upload.UploadUserProfile(
    userId: userProfileModel.userId,
    commonName: userProfileModel.commonName.orEmpty(),
    birthDate: userProfileModel.birthDate.orZero(),
    sex: userProfileModel.sex!.index.orZero(),
    occupationActivityFactor: userProfileModel.occupationActivityFactor.orZero(),
    objectives: userProfileModel.objectives.orEmpty(),
    physicalCharacteristics: physicalCharacteristics,
    medicalSituation: medicalSituation,
    femaleCharacteristics: femaleCharacteristics,
    foodAversions: userProfileModel.foodAversions,
    exclusions: exclusions,
    intolerances: userProfileModel.intolerances?.orEmpty().convertToBinary(Constants.INTOLERANCES_SIZE),
    guts: userProfileModel.guts ?? 0,
    micronutrients: userProfileModel.micronutrients,
    userRdas: uploadUserRdas.userRdas,
    feces: userProfileModel.feces,
    urine: userProfileModel.urine,
    recommededIds: userProfileModel.recommededIds,
    kcal: userProfileModel.kcal,
  );

  return profile;
}

String _setExclusions({List<int> allergens = const [], int? dietType}) {
  List<int> allergensList = [];
  if (dietType != null) { allergensList.add(dietType); }

  return allergensList.convertToBinary(Constants.EXCLUSIONS_SIZE);
}

entity.UserProfileEntity mapToProfileEntity(domain.UserProfileModel profileModel) {
  return entity.UserProfileEntity(
    userId: profileModel.userId,
    commonName: profileModel.commonName.orEmpty(),
    birthDate: profileModel.birthDate.orZero(),
    sex: profileModel.sex!.index,
    occupationActivityFactor: profileModel.occupationActivityFactor.orZero(),
    physicalCharacteristics: entity.PhysicalCharacteristics(
        weight: profileModel.physicalCharacteristics!.weight!,
        height: profileModel.physicalCharacteristics!.height!,
        // TODO: estos dos no son necesarios. No hay por qué poner valor.
      unit: profileModel.physicalCharacteristics?.unit,
        bodyFat: profileModel.physicalCharacteristics!.bodyFat,
        waistMeasurement: profileModel.physicalCharacteristics!.waistMeasurement,
    ),
    medicalSituation: entity.MedicalSituation(
        commonDiseases: profileModel.medicalSituation!.commonDiseases.orEmpty(),
        otherDiseases: profileModel.medicalSituation!.otherDiseases.orEmpty(),
        underPharmaceuticalTreatment: profileModel.medicalSituation!.underPharmaceuticalTreatment,
    ),
    femaleCharacteristics: profileModel.femaleCharacteristics != null
        ? entity.FemaleCharacteristics(
            menstruation: entity.Menstruation(
                regularity: profileModel.femaleCharacteristics!.menstruation!.regularity!,
                lastStartDate: profileModel.femaleCharacteristics!.menstruation!.lastStartDate,
                daysOfCycle: profileModel.femaleCharacteristics!.menstruation!.daysOfCycle,
            ),
          )
        : null,
    exclusions: entity.Exclusions(exclusions: profileModel.exclusions!.exclusions.orEmpty()),
    intolerances: profileModel.intolerances,
    dietType: profileModel.dietType,
    foodAversions: profileModel.foodAversions,
    objectives: profileModel.objectives.orEmpty(),
    guts: profileModel.guts,
    micronutrients: profileModel.micronutrients,
    userRdas: entity.UserRdasEntity(userRdasEntity: profileModel.userRdas!.userRdas.map((userRdas) => entity.UserRdaEntity(n: userRdas.name, rda: userRdas.rda.toDouble(), ul: userRdas.ul.toDouble())).toList()),
    feces: profileModel.feces,
    urine: profileModel.urine,
    recommededIds: profileModel.recommededIds,
    kcal: profileModel.kcal,
  );
}

domain.UserProfileModel mapToUserProfileModelFromProfileEntity(entity.UserProfileEntity profileEntity) {
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
    height: profileEntity.physicalCharacteristics!.height,
    weight: profileEntity.physicalCharacteristics!.weight,
    unit: profileEntity.physicalCharacteristics?.unit,
    bodyFat: profileEntity.physicalCharacteristics!.bodyFat,
    waistMeasurement: profileEntity.physicalCharacteristics!.waistMeasurement,
  );

  final domain.FemaleCharacteristics? femaleCharacteristics = profileEntity.sex == 0
      ? null
      : domain.FemaleCharacteristics(
      menstruation: domain.Menstruation(
        regularity: profileEntity.femaleCharacteristics!.menstruation!.regularity,
        daysOfCycle: profileEntity.femaleCharacteristics!.menstruation!.regularity == 0
            ? profileEntity.femaleCharacteristics!.menstruation!.daysOfCycle
            : null,
        lastStartDate: profileEntity.femaleCharacteristics!.menstruation!.regularity == 0
            ? profileEntity.femaleCharacteristics!.menstruation!.lastStartDate
            : null,
      ),
  );

  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
      commonDiseases: profileEntity.medicalSituation!.commonDiseases,
      otherDiseases: profileEntity.medicalSituation!.otherDiseases,
      underPharmaceuticalTreatment: profileEntity.medicalSituation!.underPharmaceuticalTreatment,
  );

  final domain.Exclusions exclusions = domain.Exclusions(
      exclusions: profileEntity.exclusions!.exclusions,
  );

  final DietType dietType = findDietType(profileEntity.dietType ?? 0);

  final intolerances = profileEntity.intolerances;

  final userRdas = domain.UserRdas(userRdas: profileEntity.userRdas!.userRdasEntity.map((userRdas) => domain.UserRda(name: userRdas.n, rda: userRdas.rda, ul: userRdas.ul)).toList());

  return domain.UserProfileModel(
    userId: profileEntity.userId,
    commonName: profileEntity.commonName,
    birthDate: profileEntity.birthDate,
    sex: profileEntity.sex == 0 ? domain.SexType.male : domain.SexType.female,
    occupationActivityFactor: profileEntity.occupationActivityFactor,
    objectives: profileEntity.objectives,
    physicalCharacteristics: physicalCharacteristics,
    femaleCharacteristics: profileEntity.sex == 0 ? null : femaleCharacteristics,
    medicalSituation: medicalSituation,
    foodAversions: profileEntity.foodAversions,
    exclusions: exclusions,
    dietType: dietType.id,
    intolerances: intolerances,
    symptoms: '',
    guts: profileEntity.guts,
    micronutrients: profileEntity.micronutrients,
    userRdas: userRdas,
    feces: profileEntity.feces,
    urine: profileEntity.urine,
    recommededIds: profileEntity.recommededIds,
    kcal: profileEntity.kcal,
  );
}

domain.UserProfileModel mapToUserProfileModelFromUploadUser(upload.UploadUserProfile uploadUserProfile) {
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
      height: uploadUserProfile.physicalCharacteristics!.height,
      weight: uploadUserProfile.physicalCharacteristics!.weight,
      unit: uploadUserProfile.physicalCharacteristics?.unit,
      bodyFat: uploadUserProfile.physicalCharacteristics!.bodyFat,
      waistMeasurement: uploadUserProfile.physicalCharacteristics!.waistMeasurement,
  );

  final domain.FemaleCharacteristics? femaleCharacteristics = uploadUserProfile.sex == 0
      ? null
      : domain.FemaleCharacteristics(
      menstruation: domain.Menstruation(
        regularity: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity,
        daysOfCycle: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity == 0
          ? uploadUserProfile.femaleCharacteristics!.menstruation!.daysOfCycle
          : null,
        lastStartDate: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity == 0
            ? uploadUserProfile.femaleCharacteristics!.menstruation!.lastStartDate
            : null,
      ),
  );

  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
    commonDiseases: convertToList(uploadUserProfile.medicalSituation!.commonDiseases),
    otherDiseases: uploadUserProfile.medicalSituation!.otherDiseases ?? [],
    underPharmaceuticalTreatment: uploadUserProfile.medicalSituation!.underPharmaceuticalTreatment,
  );

  final domain.Exclusions exclusions = domain.Exclusions(
    exclusions: convertToList(uploadUserProfile.exclusions!.substring(0, Constants.ALLERGENS_SIZE-1)),
  );

  final DietType dietType = getDietType(uploadUserProfile.exclusions.orEmpty());

  final intolerances = convertToList(uploadUserProfile.intolerances);

  final userRdas = domain.UserRdas(userRdas: uploadUserProfile.userRdas!.map((userRdas) => domain.UserRda(name: userRdas.n, rda: userRdas.rda, ul: userRdas.ul)).toList());

  return domain.UserProfileModel(
    userId: uploadUserProfile.userId,
    commonName: uploadUserProfile.commonName,
    birthDate: uploadUserProfile.birthDate,
    sex: uploadUserProfile.sex == 0 ? domain.SexType.male : domain.SexType.female,
    occupationActivityFactor: uploadUserProfile.occupationActivityFactor,
    objectives: uploadUserProfile.objectives,
    physicalCharacteristics: physicalCharacteristics,
    femaleCharacteristics: uploadUserProfile.sex == 0 ? null : femaleCharacteristics,
    medicalSituation: medicalSituation,
    foodAversions: uploadUserProfile.foodAversions,
    exclusions: exclusions,
    dietType: dietType.id,
    intolerances: intolerances,
    symptoms: '',
    guts: uploadUserProfile.guts,
    micronutrients: uploadUserProfile.micronutrients,
    userRdas: userRdas,
    feces: uploadUserProfile.feces,
    urine: uploadUserProfile.urine,
    recommededIds: uploadUserProfile.recommededIds,
    kcal: uploadUserProfile.kcal,
  );
}

List<int> convertToList(String? binary) {
  if (binary.isNull()) return [];

  final list = <int>[];
  final binaryArray = binary!.split('');
  for (var i = 0; i <= binaryArray.length - 1; i++) {
    if (binaryArray[i] != '0') list.add(i);
  }

  return list;
}

DietType getDietType(String exclusions) {
  var id = 0;
  final binaryArray = exclusions.split('');
  for (var i = Constants.ALLERGENS_SIZE; i < binaryArray.length; i++) {
    if (binaryArray[i] == '1') {
      id = i;
    }
  }
  return findDietType(id);
}

DietType findDietType(int dietId) {
  final dietTypes = DietType.listAllDietsButVegetarian();
  final dietType = dietTypes.firstWhere((diet) => diet.id == dietId, orElse: () => Omnivorous());
  return dietType;
}