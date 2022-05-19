import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';

import '../../data/api/profile/model/upload_user_profile.dart' as upload;
import '../../data/local/models/profile/user_profile_entity.dart' as entity;
import '../../domain/models/profile/user_profile_model.dart';
import '../../infrastructure/extensions/extensions.dart';
import '../utils/constants.dart';

upload.UploadUserProfile mapToUploadUserProfileModel(UserProfileModel userProfileModel) {
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
      // TODO: estos dos de abajo van a null si el de arriba no es regular.
      daysOfCycle: userProfileModel.femaleCharacteristics?.menstruation?.daysOfCycle,
      lastStartDate: userProfileModel.femaleCharacteristics?.menstruation?.lastStartDate
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
    exclusions: upload.Exclusions(exclusions: exclusions),
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

entity.UserProfileEntity mapToProfileEntity(UserProfileModel profileModel) {
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

// UserProfileModel mapToUserProfileModel(entity.UserProfileEntity entity) {
//   return UserProfileModel();
// }