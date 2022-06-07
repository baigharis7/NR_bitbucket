import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart' as upload;
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart' as entity;
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart' as domain;
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

upload.UploadUserProfile mapToUploadUserProfileModel(domain.UserProfileModel userProfileModel) {
  final upload.PhysicalCharacteristics physicalCharacteristics = upload.PhysicalCharacteristics(
    height: userProfileModel.physicalCharacteristics!.height,
    weight: userProfileModel.physicalCharacteristics!.weight,
    bodyFat: userProfileModel.physicalCharacteristics!.bodyFat,
    waistMeasurement: userProfileModel.physicalCharacteristics!.waistMeasurement
  );

  final upload.FemaleCharacteristics? femaleCharacteristics = userProfileModel.sex.index == upload.SexType.male.index
      ? null
      : upload.FemaleCharacteristics(
      menstruation: upload.Menstruation(
      regularity: userProfileModel.femaleCharacteristics?.menstruation?.regularity ?? 0,
      daysOfCycle: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 1
          ? userProfileModel.femaleCharacteristics?.menstruation?.daysOfCycle
          : null,
      lastStartDate: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 1
          ? userProfileModel.femaleCharacteristics?.menstruation?.lastStartDate
          : null
    )
  );

  final upload.MedicalSituation? medicalSituation = upload.MedicalSituation(
    commonDiseases: userProfileModel.medicalSituation!.commonDiseases.convertToBinary(Constants.DISEASES_SIZE),
    otherDiseases: userProfileModel.medicalSituation!.otherDiseases,
    underPharmaceuticalTreatment: userProfileModel.medicalSituation!.underPharmaceuticalTreatment
  );

  final String exclusions = _setExclusions(
      allergens: userProfileModel.exclusions!.exclusions,
      dietType: userProfileModel.dietType
  );

  final profile = upload.UploadUserProfile(
    userId: userProfileModel.userId,
    commonName: userProfileModel.commonName,
    birthDate: userProfileModel.birthDate,
    sex: userProfileModel.sex.index,
    occupationActivityFactor: userProfileModel.occupationActivityFactor,
    objectives: userProfileModel.objectives,
    physicalCharacteristics: physicalCharacteristics,
    medicalSituation: medicalSituation,
    femaleCharacteristics: femaleCharacteristics,
    foodAversions: userProfileModel.foodAversions,
    exclusions: exclusions,
    intolerances: userProfileModel.intolerances?.orEmpty().convertToBinary(Constants.INTOLERANCES_SIZE),
    guts: userProfileModel.guts ?? 0,
    micronutrients: userProfileModel.micronutrients
  );

  return profile;
}

String _setExclusions({List<int> allergens = const [], int? dietType}) {
  List<int> allergensList = [];
  if (dietType != null) { allergensList.add(dietType); }

  return allergensList.convertToBinary(Constants.EXCLUSIONS_SIZE + Constants.DIET_TYPES_SIZE);
}

entity.UserProfileEntity mapToProfileEntity(domain.UserProfileModel profileModel) {
  return entity.UserProfileEntity(
    userId: profileModel.userId,
    commonName: profileModel.commonName,
    birthDate: profileModel.birthDate,
    sex: profileModel.sex.index,
    occupationActivityFactor: profileModel.occupationActivityFactor,
    physicalCharacteristics: entity.PhysicalCharacteristics(
        weight: profileModel.physicalCharacteristics!.weight,
        height: profileModel.physicalCharacteristics!.height,
        // TODO: estos dos no son necesarios. No hay por qué poner valor.
        bodyFat: profileModel.physicalCharacteristics!.bodyFat,
        waistMeasurement: profileModel.physicalCharacteristics!.waistMeasurement),
    medicalSituation: entity.MedicalSituation(
        commonDiseases: profileModel.medicalSituation!.commonDiseases,
        otherDiseases: profileModel.medicalSituation!.otherDiseases,
        underPharmaceuticalTreatment: profileModel.medicalSituation!.underPharmaceuticalTreatment
    ),
    femaleCharacteristics: profileModel.femaleCharacteristics != null
        ? entity.FemaleCharacteristics(
            menstruation: entity.Menstruation(
                regularity: profileModel.femaleCharacteristics!.menstruation!.regularity,
                lastStartDate: profileModel.femaleCharacteristics!.menstruation!.lastStartDate,
                daysOfCycle: profileModel.femaleCharacteristics!.menstruation!.daysOfCycle
            ),
          )
        : null,
    exclusions: entity.Exclusions(exclusions: profileModel.exclusions!.exclusions.orEmpty()),
    intolerances: profileModel.intolerances,
    dietType: profileModel.dietType,
    foodAversions: profileModel.foodAversions,
    objectives: profileModel.objectives,
    guts: profileModel.guts,
    micronutrients: profileModel.micronutrients
  );
}

domain.UserProfileModel mapToUserProfileModelFromProfileEntity(entity.UserProfileEntity profileEntity) {
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
    height: profileEntity.physicalCharacteristics!.height,
    weight: profileEntity.physicalCharacteristics!.weight,
    bodyFat: profileEntity.physicalCharacteristics!.bodyFat,
    waistMeasurement: profileEntity.physicalCharacteristics!.waistMeasurement,
  );

  final domain.FemaleCharacteristics? femaleCharacteristics = profileEntity.sex == 0
      ? null
      : domain.FemaleCharacteristics(
      menstruation: domain.Menstruation(
        regularity: profileEntity.femaleCharacteristics!.menstruation!.regularity,
        daysOfCycle: profileEntity.femaleCharacteristics!.menstruation!.regularity == 1
            ? profileEntity.femaleCharacteristics!.menstruation!.daysOfCycle
            : null,
        lastStartDate: profileEntity.femaleCharacteristics!.menstruation!.regularity == 1
            ? profileEntity.femaleCharacteristics!.menstruation!.lastStartDate
            : null,
      )
  );

  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
      commonDiseases: profileEntity.medicalSituation!.commonDiseases,
      otherDiseases: profileEntity.medicalSituation!.otherDiseases,
      underPharmaceuticalTreatment: profileEntity.medicalSituation!.underPharmaceuticalTreatment
  );

  final domain.Exclusions exclusions = domain.Exclusions(
      exclusions: profileEntity.exclusions!.exclusions
  );

  final DietType dietType = findDietType(profileEntity.dietType ?? 0);

  final intolerances = profileEntity.intolerances;

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
      micronutrients: profileEntity.micronutrients
  );
}

domain.UserProfileModel mapToUserProfileModelFromUploadUser(upload.UploadUserProfile uploadUserProfile) {
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
      height: uploadUserProfile.physicalCharacteristics!.height,
      weight: uploadUserProfile.physicalCharacteristics!.weight,
      bodyFat: uploadUserProfile.physicalCharacteristics!.bodyFat,
      waistMeasurement: uploadUserProfile.physicalCharacteristics!.waistMeasurement,
  );

  final domain.FemaleCharacteristics? femaleCharacteristics = uploadUserProfile.sex == 0
      ? null
      : domain.FemaleCharacteristics(
      menstruation: domain.Menstruation(
        regularity: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity,
        daysOfCycle: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity == 1
          ? uploadUserProfile.femaleCharacteristics!.menstruation!.daysOfCycle
          : null,
        lastStartDate: uploadUserProfile.femaleCharacteristics!.menstruation!.regularity == 1
            ? uploadUserProfile.femaleCharacteristics!.menstruation!.lastStartDate
            : null,
      )
  );

  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
    commonDiseases: convertToList(uploadUserProfile.medicalSituation!.commonDiseases),
    otherDiseases: uploadUserProfile.medicalSituation!.otherDiseases ?? [],
    underPharmaceuticalTreatment: uploadUserProfile.medicalSituation!.underPharmaceuticalTreatment
  );

  final domain.Exclusions exclusions = domain.Exclusions(
    exclusions: convertToList(uploadUserProfile.exclusions!.substring(0, Constants.ALLERGENS_SIZE-1))
  );

  final DietType dietType = getDietType(uploadUserProfile.exclusions.orEmpty());

  final intolerances = convertToList(uploadUserProfile.intolerances);

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
      micronutrients: uploadUserProfile.micronutrients
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
  final dietTypes = DietType.listAllDietTypes();
  final dietType = dietTypes.firstWhere((diet) => diet.id == dietId, orElse: () => Omnivorous());
  return dietType;
}