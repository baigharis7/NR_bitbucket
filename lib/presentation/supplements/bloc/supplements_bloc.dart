import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';

import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/mappers/supplement_mappers.dart';
import '../../../infrastructure/utils/crashlytics_service.dart';

part 'supplements_event.dart';

part 'supplements_state.dart';

class SupplementsBloc extends Bloc<SupplementsEvent, SupplementsState> {
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSupplementEventInteractor uploadSupplementEventInteractor;
  final SaveSupplementEventInteractor saveSupplementEventInteractor;
  final UploadSupplementFavoriteInteractor uploadSupplementFavoriteInteractor;
  final SaveSupplementFavoriteInteractor saveSupplementFavoriteInteractor;
  final GetSupplementFavoritesInteractor getSupplementFavoritesInteractor;
  final UploadSupplementRoutineInteractor uploadSupplementRoutineInteractor;
  final SaveSupplementRoutineInteractor saveSupplementRoutineInteractor;
  final GetUserIdInteractor getUserIdInteractor;

  SupplementsBloc({
    required this.getProfileInteractor,
    required this.getMasterFileInteractor,
    required this.uploadSupplementEventInteractor,
    required this.saveSupplementEventInteractor,
    required this.uploadSupplementFavoriteInteractor,
    required this.saveSupplementFavoriteInteractor,
    required this.getSupplementFavoritesInteractor,
    required this.uploadSupplementRoutineInteractor,
    required this.saveSupplementRoutineInteractor,
    required this.getUserIdInteractor,
  }) : super(SupplementsState(isLoading: false, supplementObj: SupplementSimple.empty())) {

    on<InitializationSupplementsAction>((event, emit) async {
      _clearData();
      emit(state.copyWith(isLoading: true, onError: null));
      state.userProfile = await getProfileInteractor.execute();
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      state.supplementFavorites = await getSupplementFavoritesInteractor.execute();
      state.supplementObj?.userId = getUserIdInteractor.execute();
      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateDateSupplementsAction>((event, emit) {
      state.supplementObj?.eventDate = event.dateTime.millisecondsSinceEpoch;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<GetSupplementFromNavAction>((event, emit) async {
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      state.supplementObj = event.supplementSimple;
      state.isEdit = true;
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateScreenTitle>((event, emit) {
      state.screenTitle = event.screenTitle;

      emit(state.copyWith(isLoading: false));
    });

    on<AddSupplementInfoSupplementsAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.supplementObj!.info.orEmpty().map((food) => food.id).contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info.orEmpty().indexOf(state.supplementObj!.info.orEmpty().firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info.orEmpty().remove(state.supplementObj!.info.orEmpty()[itemIndex]);
        state.supplementObj!.info?.add(event.nutriInfo);
      } else {
        state.supplementObj!.info?.add(event.nutriInfo);
      }
      emit(state.copyWith(isLoading: false,));
    });

    on<RemoveSupplementInfoSupplementsAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.supplementObj?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info!.indexOf(state.supplementObj!.info!.firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info!.remove(state.supplementObj!.info![itemIndex]);
      }
      if (state.supplementObj?.info?.isEmpty == true && state.isEdit == true) event.isGoBack.call();
      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateAmountSupplementsAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.supplementObj!.info.orEmpty().map((food) => food.id).contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info.orEmpty().indexOf(state.supplementObj!.info.orEmpty().firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info?[itemIndex].amount = event.nutriInfo.amount;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateNameSupplementsEvent>((event, emit) {
      state.supplementObj?.name = event.name;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFavoriteActionSupplementsEvent>((event, emit) {
      state.supplementObj?.isFavorite = event.isFavorite;
      state.supplementObj?.isRoutine = event.isFavorite == true ? false : false;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateRoutineActionSupplementsEvent>((event, emit) {
      state.supplementObj?.isRoutine = event.isRoutine;
      state.supplementObj?.isFavorite = event.isRoutine == true ? false : false;

      if (event.isRoutine && state.supplementObj?.scheduleTime.isEmptyOrNull() == true) {
        state.supplementObj?.scheduleTime = DateTimeHelper.timeOfDayTo24HrString(TimeOfDay.now());
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateTimeOfDaySupplementsEvent>((event, emit) {
      state.supplementObj?.scheduleTime = event.scheduleTime;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateDaysOfWeekSupplementsEvent>((event, emit) {
      final daysOfWeek = state.supplementObj?.daysOfWeek.orEmpty() ?? [];
      if (state.supplementObj?.daysOfWeek.orEmpty().contains(event.weekDay) ?? false) {
        state.supplementObj?.daysOfWeek?.remove(event.weekDay);
      } else {
        state.supplementObj?.daysOfWeek?.add(event.weekDay);
      }

      emit(state.copyWith(isLoading: false));
    });

    on<SavingEventSupplementsAction>((event, emit) {
      if (state.supplementObj?.info.orEmpty().isEmpty == true) return;

      if (state.supplementObj?.isFavorite == true) {
        add(FinishSupplementFavorite(onFinish: () {}));
      } else if (state.supplementObj?.isRoutine == true) {
        if (state.supplementObj?.daysOfWeek?.isEmpty == true || state.supplementObj?.scheduleTime.isEmptyOrNull() == true) return;
        add(FinishSupplementRoutineSupplementsEvent(onFinish: () {}));
      } else {
        add(FinishEventSupplementsAction(onFinish: event.onFinish));
      }
    });

    on<FinishEventSupplementsAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        state.supplementObj?.userId = getUserIdInteractor.execute();
        state.supplementObj?.eventId = state.supplementObj?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        final uploadSupplements = mapToUploadSupplementsEv(state.supplementObj!);
        await uploadSupplementEventInteractor.execute(uploadSupplements);
        try {
          await saveSupplementEventInteractor.execute(state.supplementObj!, state.isEdit ?? false);
          DashboardEventBus.instance.notify(DataChangedCategory.supplement);
          _clearData();
          emit(state.copyWith(isLoading: false));
          event.onFinish.call();
        } catch(error, st) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementEventError));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Supplement logging local',
              'screen': 'Add Supplement',
              'event data': state.supplementObj.toString(),
            },
          );
        }
      } catch(error, st) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementEventError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Supplement logging',
            'screen': 'Add Supplement',
            'event data': state.supplementObj.toString(),
          },
        );
      }
    });

    on<FinishSupplementFavorite>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        state.supplementObj?.userId = getUserIdInteractor.execute();
        state.supplementObj?.eventId = state.supplementObj?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        final uploadSupplementFavorite = mapToSupplementFavoriteFromSupplement(state.supplementObj!);
        await uploadSupplementFavoriteInteractor.execute(uploadSupplementFavorite);
        try {
          await saveSupplementFavoriteInteractor.execute(uploadSupplementFavorite, state.isEdit ?? false);
          state.supplementFavorites = await getSupplementFavoritesInteractor.execute();

          // Also log the item as an event
          try {
            final supplementForEvent = state.supplementObj!;
            final eventId = DateTime.now().millisecondsSinceEpoch;
            supplementForEvent.eventId = eventId;
            final uploadSupplements = mapToUploadSupplementsEv(supplementForEvent);
            await uploadSupplementEventInteractor.execute(uploadSupplements);
            await saveSupplementEventInteractor.execute(supplementForEvent, false);
            DashboardEventBus.instance.notify(DataChangedCategory.supplement);
          } catch (error, st) {
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Supplement event logging alongside favorite',
                'screen': 'Add Supplement',
                'event data': state.supplementObj.toString(),
              },
            );
          }

          _clearData();
          emit(state.copyWith(isLoading: false));
          event.onFinish.call();
        } catch(error, st) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSupplementFavoriteError));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Supplement favorite logging local',
              'screen': 'Add Supplement',
              'event data': state.supplementObj.toString(),
            },
          );
        }
      } catch(error, st) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementFavoriteError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Supplement favorite logging',
            'screen': 'Add Supplement',
            'event data': state.supplementObj.toString(),
          },
        );
      }
    });

    on<FinishSupplementRoutineSupplementsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        state.supplementObj?.userId = getUserIdInteractor.execute();
        state.supplementObj?.eventId = state.supplementObj?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
        final uploadSupplementRoutine = mapToSupplementRoutineFromSupplement(state.supplementObj!);
        await uploadSupplementRoutineInteractor.execute(uploadSupplementRoutine);
        try {
          await saveSupplementRoutineInteractor.execute(uploadSupplementRoutine, false);
          DashboardEventBus.instance.notify(DataChangedCategory.supplement);

          _clearData();
          emit(state.copyWith(isLoading: false));
          event.onFinish.call();
        } catch(error, st) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSupplementRoutineError));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Supplement routine logging local',
              'screen': 'Add Supplement',
              'event data': state.supplementObj.toString(),
            },
          );
        }
      } catch(error, st) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementRoutineError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Supplement routine logging',
            'screen': 'Add Supplement',
            'event data': state.supplementObj.toString(),
          },
        );
      }
    });

    on<FinishSupplementFavoriteSupplementsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        event.supplement.userId = getUserIdInteractor.execute();
        event.supplement.eventId = DateTime.now().millisecondsSinceEpoch;
        event.supplement.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        final uploadSupplements = mapToUploadSupplementsEv(event.supplement);
        await uploadSupplementEventInteractor.execute(uploadSupplements);
        try {
          await saveSupplementEventInteractor.execute(event.supplement, false);
          DashboardEventBus.instance.notify(DataChangedCategory.supplement);
          _clearData();
          emit(state.copyWith(isLoading: false));
          event.onFinish.call();
        } catch(_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementEventError));
        }
      } catch(_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementEventError));
      }
    });
  }
  void _clearData() {
    state.screenTitle = null;
    state.isEdit = null;
    state.supplementObj = SupplementSimple.empty();
  }
}
