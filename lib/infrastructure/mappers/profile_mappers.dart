import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart' as upload;
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart' as entity;
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart' as domain;
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

// Every `!` in this file used to crash a real user. Audit history:
//   - 265 (downloadProfile mapper): female accounts missing femaleCharacteristics
//   - 268 (saveProfileInLocal mapper): orphan-content menstruation (regularity null)
//   - 269 (this sweep): all remaining `!` chains converted to `?.` + safe defaults
// Pattern: trust nothing at read time. Boundary validation (signup form, Lambda
// schema check) is the *only* guarantee these fields exist; reads must tolerate
// drift from migrations, partial server responses, legacy schemas, etc.
upload.UploadUserProfile mapToUploadUserProfileModel(domain.UserProfileModel userProfileModel) {
  final pc = userProfileModel.physicalCharacteristics;
  final upload.PhysicalCharacteristics physicalCharacteristics = upload.PhysicalCharacteristics(
    height: pc?.height ?? 0.0,
    weight: pc?.weight ?? 0.0,
    unit: pc?.unit,
    bodyFat: pc?.bodyFat,
    waistMeasurement: pc?.waistMeasurement,
  );

  // Default to female index (1) when sex is missing — matches the same default
  // mapper #4 already applies on the download side. Calc-relevant; should not
  // be null in practice (signup enforces it), but if drift happens we surface
  // the issue at boundary validation rather than crashing this mapper.
  final int sexIndex = userProfileModel.sex?.index ?? upload.SexType.female.index;
  final upload.FemaleCharacteristics? femaleCharacteristics = sexIndex == upload.SexType.male.index
      ? null
      : userProfileModel.femaleCharacteristics == null ? null : upload.FemaleCharacteristics(
          menstruation: upload.Menstruation(
            regularity: userProfileModel.femaleCharacteristics?.menstruation?.regularity,
            daysOfCycle: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 0
                ? userProfileModel.femaleCharacteristics?.menstruation?.daysOfCycle
                : null,
            lastStartDate: userProfileModel.femaleCharacteristics?.menstruation?.regularity == 0
                ? userProfileModel.femaleCharacteristics?.menstruation?.lastStartDate
                : null,
          ),
        );

  final ms = userProfileModel.medicalSituation;
  final upload.MedicalSituation medicalSituation = upload.MedicalSituation(
    commonDiseases: (ms?.commonDiseases ?? const <int>[]).convertToBinary(Constants.DISEASES_SIZE),
    otherDiseases: ms?.otherDiseases ?? const <String>[],
    underPharmaceuticalTreatment: ms?.underPharmaceuticalTreatment ?? false,
  );

  final String exclusions = _setExclusions(
      allergens: userProfileModel.exclusions?.exclusions ?? const <int>[],
      dietType: userProfileModel.dietType,
  );

  final upload.UserRdas uploadUserRdas = upload.UserRdas(
    userRdas: (userProfileModel.userRdas?.userRdas ?? const <domain.UserRda>[])
        .map((rda) => upload.UserRda(
              n: rda.name,
              rda: rda.rda,
              ul: rda.ul,
              upperLimit: rda.upperLimit ?? 0.0,
            ))
        .toList(),
  );

  final profile = upload.UploadUserProfile(
    userId: userProfileModel.userId,
    commonName: userProfileModel.commonName.orEmpty(),
    birthDate: userProfileModel.birthDate.orZero(),
    sex: sexIndex,
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
    recommededIds: userProfileModel.recommededIds,
    kcal: userProfileModel.kcal,
  );

  return profile;
}

String _setExclusions({List<int> allergens = const [], int? dietType}) {
  List<int> allergensList = [];
  allergensList.addAll(allergens);
  if (dietType != null) { allergensList.add(dietType); }

  return allergensList.convertToBinary(Constants.EXCLUSIONS_SIZE);
}

entity.UserProfileEntity mapToProfileEntity(domain.UserProfileModel profileModel) {
  final pc = profileModel.physicalCharacteristics;
  final ms = profileModel.medicalSituation;
  final fc = profileModel.femaleCharacteristics;
  return entity.UserProfileEntity(
    userId: profileModel.userId,
    commonName: profileModel.commonName.orEmpty(),
    birthDate: profileModel.birthDate.orZero(),
    sex: profileModel.sex?.index ?? domain.SexType.female.index,
    occupationActivityFactor: profileModel.occupationActivityFactor.orZero(),
    physicalCharacteristics: entity.PhysicalCharacteristics(
        weight: pc?.weight ?? 0.0,
        height: pc?.height ?? 0.0,
        unit: pc?.unit,
        bodyFat: pc?.bodyFat,
        waistMeasurement: pc?.waistMeasurement,
    ),
    medicalSituation: entity.MedicalSituation(
        commonDiseases: ms?.commonDiseases ?? const <int>[],
        otherDiseases: ms?.otherDiseases ?? const <String>[],
        underPharmaceuticalTreatment: ms?.underPharmaceuticalTreatment ?? false,
    ),
    femaleCharacteristics: fc != null
        ? entity.FemaleCharacteristics(
            // Legacy female accounts (Olatz, Luisa Desch ×2, maddi) and any
            // user who taps "Skip for now" on signup produce a non-null FC
            // with an all-null Menstruation. Entity field types are already
            // nullable; `?.` lets the orphan-content shape flow through.
            menstruation: entity.Menstruation(
                regularity: fc.menstruation?.regularity,
                lastStartDate: fc.menstruation?.lastStartDate,
                daysOfCycle: fc.menstruation?.daysOfCycle,
            ),
          )
        : null,
    exclusions: entity.Exclusions(exclusions: profileModel.exclusions?.exclusions ?? const <int>[]),
    intolerances: profileModel.intolerances,
    dietType: profileModel.dietType,
    foodAversions: profileModel.foodAversions,
    objectives: profileModel.objectives.orEmpty(),
    guts: profileModel.guts,
    micronutrients: profileModel.micronutrients,
    userAll: profileModel.userAll,
    temporaryMicronutrients: profileModel.temporaryMicronutrients,
    temporaryAll: profileModel.temporaryAll,
    userRdas: entity.UserRdasEntity(
      userRdasEntity: (profileModel.userRdas?.userRdas ?? const <domain.UserRda>[])
          .map((rda) => entity.UserRdaEntity(
                n: rda.name,
                rda: rda.rda.toDouble(),
                ul: rda.ul.toDouble(),
                upperLimit: rda.upperLimit?.toDouble() ?? 0.0,
              ))
          .toList(),
    ),
    recommededIds: profileModel.recommededIds,
    kcal: profileModel.kcal,
  );
}

domain.UserProfileModel mapToUserProfileModelFromProfileEntity(entity.UserProfileEntity profileEntity) {
  final pc = profileEntity.physicalCharacteristics;
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
    height: pc?.height ?? 0.0,
    weight: pc?.weight ?? 0.0,
    unit: pc?.unit,
    bodyFat: pc?.bodyFat,
    waistMeasurement: pc?.waistMeasurement,
  );

  final fcEntity = profileEntity.femaleCharacteristics;
  final domain.FemaleCharacteristics? femaleCharacteristics = profileEntity.sex == 0
      ? null
      : fcEntity == null ? null : domain.FemaleCharacteristics(
          menstruation: domain.Menstruation(
            regularity: fcEntity.menstruation?.regularity,
            daysOfCycle: fcEntity.menstruation?.regularity == 0
                ? fcEntity.menstruation?.daysOfCycle
                : null,
            lastStartDate: fcEntity.menstruation?.regularity == 0
                ? fcEntity.menstruation?.lastStartDate
                : null,
          ),
        );

  final msEntity = profileEntity.medicalSituation;
  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
      commonDiseases: msEntity?.commonDiseases ?? const <int>[],
      otherDiseases: msEntity?.otherDiseases ?? const <String>[],
      underPharmaceuticalTreatment: msEntity?.underPharmaceuticalTreatment ?? false,
  );

  final domain.Exclusions exclusions = domain.Exclusions(
      exclusions: profileEntity.exclusions?.exclusions ?? const <int>[],
  );

  final DietType dietType = findDietType(profileEntity.dietType ?? 0);

  final intolerances = profileEntity.intolerances;

  final userRdas = domain.UserRdas(
    userRdas: (profileEntity.userRdas?.userRdasEntity ?? const <entity.UserRdaEntity>[])
        .map((rda) => domain.UserRda(name: rda.n, rda: rda.rda, ul: rda.ul, upperLimit: rda.upperLimit))
        .toList(),
  );

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
    userAll: profileEntity.userAll,
    temporaryMicronutrients: profileEntity.temporaryMicronutrients,
    temporaryAll: profileEntity.temporaryAll,
    userRdas: userRdas,
    recommededIds: profileEntity.recommededIds,
    kcal: profileEntity.kcal,
  );
}

domain.UserProfileModel mapToUserProfileModelFromUploadUser(upload.UploadUserProfile uploadUserProfile) {
  final pc = uploadUserProfile.physicalCharacteristics;
  final domain.PhysicalCharacteristics physicalCharacteristics = domain.PhysicalCharacteristics(
      height: pc?.height ?? 0.0,
      weight: pc?.weight ?? 0.0,
      unit: pc?.unit,
      bodyFat: pc?.bodyFat,
      waistMeasurement: pc?.waistMeasurement,
  );

  // Female users registered via older versions of the signup flow could land
  // here with femaleCharacteristics absent (the menstruation question was
  // skippable). Defaulting the inner fields to null keeps the rest of the
  // profile loadable; femaleCharacteristics isn't read by any calc path.
  final menstruation = uploadUserProfile.femaleCharacteristics?.menstruation;
  final domain.FemaleCharacteristics? femaleCharacteristics = uploadUserProfile.sex == 0
      ? null
      : domain.FemaleCharacteristics(
          menstruation: domain.Menstruation(
            regularity: menstruation?.regularity,
            daysOfCycle: menstruation?.regularity == 0 ? menstruation?.daysOfCycle : null,
            lastStartDate: menstruation?.regularity == 0 ? menstruation?.lastStartDate : null,
          ),
        );

  final ms = uploadUserProfile.medicalSituation;
  final domain.MedicalSituation medicalSituation = domain.MedicalSituation(
    commonDiseases: convertToList(ms?.commonDiseases),
    otherDiseases: ms?.otherDiseases ?? const <String>[],
    underPharmaceuticalTreatment: ms?.underPharmaceuticalTreatment ?? false,
  );

  // RangeError-safe substring: a backend record shorter than the schema's
  // ALLERGENS_SIZE shouldn't crash login. Truncate only when long enough.
  final exclusionsRaw = uploadUserProfile.exclusions ?? '';
  final exclusionsTrimmed = exclusionsRaw.length >= Constants.ALLERGENS_SIZE - 1
      ? exclusionsRaw.substring(0, Constants.ALLERGENS_SIZE - 1)
      : exclusionsRaw;
  final domain.Exclusions exclusions = domain.Exclusions(
    exclusions: convertToList(exclusionsTrimmed),
  );

  final DietType dietType = getDietType(exclusionsRaw);

  final intolerances = convertToList(uploadUserProfile.intolerances);

  final userRdas = domain.UserRdas(
    userRdas: (uploadUserProfile.userRdas ?? const <upload.UserRda>[])
        .map((rda) => domain.UserRda(name: rda.n, rda: rda.rda, ul: rda.ul, upperLimit: rda.upperLimit))
        .toList(),
  );

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
    userAll: uploadUserProfile.userAll,
    temporaryMicronutrients: uploadUserProfile.temporaryMicronutrients,
    temporaryAll: uploadUserProfile.temporaryAll,
    userRdas: userRdas,
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