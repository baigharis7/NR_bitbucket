import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/delete_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/remove_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/delete_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/routines/remove_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_routines_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodroutines/get_food_routines_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/sportevents/remove_sport_event_interactor.dart';
import '../../../domain/interactor/supplements/remove_supplement_routine_interactor.dart';
import '../../../domain/models/foodroutine/food_routine_event.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/sports_info_master.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/masterfiles/units_info_master.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';
import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'routines_tab_event.dart';
part 'routines_tab_state.dart';

class RoutinesTabBloc extends Bloc<RoutinesTabEvent, RoutinesTabState> {
  final GetFoodRoutinesInteractor getFoodRoutinesInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetRoutinesInteractor getRoutinesInteractor;
  final GetSupplementRoutinesInteractor getSupplementRoutinesInteractor;
  final DeleteFoodRoutineInteractor deleteFoodRoutineInteractor;
  final RemoveFoodRoutineInteractor removeFoodRoutineInteractor;
  final DeleteSportRoutineInteractor deleteSportRoutineInteractor;
  final RemoveSportRoutineInteractor removeSportRoutineInteractor;
  final DeleteSupplementRoutineInteractor deleteSupplementRoutineInteractor;
  final RemoveSupplementRoutineInteractor removeSupplementRoutineInteractor;
  RoutinesTabBloc({
    required this.getFoodRoutinesInteractor,
    required this.getMasterFileInteractor,
    required this.getRoutinesInteractor,
    required this.getSupplementRoutinesInteractor,
    required this.deleteFoodRoutineInteractor,
    required this.removeFoodRoutineInteractor,
    required this.deleteSportRoutineInteractor,
    required this.removeSportRoutineInteractor,
    required this.deleteSupplementRoutineInteractor,
    required this.removeSupplementRoutineInteractor,
  }) : super(RoutinesTabState(isLoading: false)) {
    on<InitializeRoutinesTabEvent>((event, emit) async {
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      final foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.foodNames = foodNames;
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.mealRoutines = await getFoodRoutinesInteractor.execute();
      state.sportRoutines = await getRoutinesInteractor.execute();
      state.supplementRoutines = await getSupplementRoutinesInteractor.execute();
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);

      emit(state.copyWith(isLoading: false));
    });

    on<DeleteFoodRoutineActionRoutinesTabEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteFoodRoutineInteractor.execute(event.foodRoutineEvent);
        try {
          // throw Exception('');
          await removeFoodRoutineInteractor.execute(event.foodRoutineEvent);
          state.mealRoutines = await getFoodRoutinesInteractor.execute();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removerFoodRoutineError));
        }
      } catch(_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodRoutineError));
      }
    });

    on<DeleteSportRoutineAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteSportRoutineInteractor.execute(event.sportRoutineCompleted.userId ?? '', event.sportRoutineCompleted.eventId ?? 0);
        try {
          // throw Exception('');
          await removeSportRoutineInteractor.execute(event.sportRoutineCompleted);
          state.sportRoutines = await getRoutinesInteractor.execute();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportRoutineError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportRoutineError));
      }
    });

    on<DeleteSupplementRoutineRoutinesTabEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteSupplementRoutineInteractor.execute(event.supplement);
        try {
          // throw Exception('');
          await removeSupplementRoutineInteractor.execute(event.supplement);
          state.supplementRoutines = await getSupplementRoutinesInteractor.execute();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportRoutineError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportRoutineError));
      }
    });
  }
}
