import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/api/profile/model/user_profile_response.dart';
import '../../../domain/interactor/profile/upload_profile_interactor.dart';
import '../../../domain/models/profile/feces.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'feces_urine_event.dart';

part 'feces_urine_state.dart';

class FecesUrineBloc extends Bloc<FecesUrineEvent, FecesUrineState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetProfileInteractor getProfileInteractor;
  final UploadProfileInteractor uploadProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;

  FecesUrineBloc({
    required this.getUserIdInteractor,
    required this.getProfileInteractor,
    required this.uploadProfileInteractor,
    required this.saveProfileInteractor,
  }) : super(FecesUrineState(isLoading: false)) {
    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      state.urinesList = Urines.listOfAllUrines();
      state.profile = await getProfileInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFecesEventAction>(
      (event, emit) {
        emit(state.copyWith(isLoading: true));
        state.profile?.feces = event.feceId;

        emit(state.copyWith(isLoading: false));
      },
    );

    on<UpdateUrineEventAction>(
      (event, emit) {
        emit(state.copyWith(isLoading: true));
        state.profile?.urine = event.urineId;

        emit(state.copyWith(isLoading: false));
      },
    );

    on<UpdateProfileEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      FemaleCharacteristics? femaleCharacteristics;
      if (state.profile!.sex == SexType.female) {
        femaleCharacteristics = FemaleCharacteristics(
          menstruation: Menstruation(
            regularity: state.profile!.femaleCharacteristics!.menstruation!.regularity,
            daysOfCycle: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.daysOfCycle,
            lastStartDate: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.lastStartDate,
          ),
        );
      } else {
        femaleCharacteristics = null;
      }

      UserProfileModel profile = UserProfileModel(
        userId: getUserIdInteractor.execute(),
        commonName: state.profile?.commonName?.orEmpty(),
        birthDate: state.profile!.birthDate,
        sex: state.profile!.sex,
        occupationActivityFactor: state.profile!.occupationActivityFactor ?? 1.2,
        physicalCharacteristics: PhysicalCharacteristics(
          height: state.profile!.physicalCharacteristics!.height,
          weight: state.profile!.physicalCharacteristics!.weight,
          unit: state.profile?.physicalCharacteristics?.unit,
          bodyFat: state.profile!.physicalCharacteristics!.bodyFat,
          waistMeasurement: state.profile!.physicalCharacteristics!.waistMeasurement,),
        femaleCharacteristics: femaleCharacteristics,
        medicalSituation: MedicalSituation(
          commonDiseases: state.profile!.medicalSituation!.commonDiseases,
          otherDiseases: [], // Añadir a pantalla
          // underPharmaceuticalTreatment: isUnderTreatment,
        ),
        foodAversions: state.profile!.foodAversions,
        dietType: state.profile!.dietType ?? 0,
        exclusions: Exclusions(exclusions: state.profile!.exclusions!.exclusions),
        intolerances: state.profile!.intolerances,
        // symptoms: , // Añadir cuando esté implementado
        guts: 0,
        objectives: state.profile!.objectives,
        feces: state.profile?.feces ?? -1,
        urine: state.profile?.urine ?? -1,
      );

      UserProfileResponse userProfileResponse;
      try {
        userProfileResponse = await uploadProfileInteractor.execute(profile);
        if (userProfileResponse.uploadSuccess) {
          profile.micronutrients = userProfileResponse.micronutrients;
          profile.userRdas = UserRdas(
            userRdas: userProfileResponse.userRdas.map((userRda) => UserRda(name: userRda.n, rda: userRda.rda, ul: userRda.ul)).toList(),
          );
          profile.kcal = userProfileResponse.kcal;
          try {
            await saveProfileInteractor.execute(profile);
            // add(InitializeState());
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.savingProfileError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingProfileError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingProfileError));
      }
    },);
  }
}
