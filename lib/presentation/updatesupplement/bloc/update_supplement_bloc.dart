import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/preferences/get_user_id_interactor.dart';
import '../../../domain/interactor/supplements/save_supplement_favorite_interactor.dart';
import '../../../domain/interactor/supplements/upload_supplement_favorite_interactor.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/mappers/supplement_mappers.dart';

part 'update_supplement_event.dart';

part 'update_supplement_state.dart';

class UpdateSupplementBloc
    extends Bloc<UpdateSupplementEvent, UpdateSupplementState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSupplementFavoriteInteractor uploadSupplementFavoriteInteractor;
  final SaveSupplementFavoriteInteractor saveSupplementFavoriteInteractor;
  final UploadSupplementRoutineInteractor uploadSupplementRoutineInteractor;
  final SaveSupplementRoutineInteractor saveSupplementRoutineInteractor;
  final GetUserIdInteractor getUserIdInteractor;

  UpdateSupplementBloc({
    required this.getMasterFileInteractor,
    required this.uploadSupplementFavoriteInteractor,
    required this.saveSupplementFavoriteInteractor,
    required this.uploadSupplementRoutineInteractor,
    required this.saveSupplementRoutineInteractor,
    required this.getUserIdInteractor,
  }) : super(UpdateSupplementState(isLoading: false)) {
    on<InitializationUpdateSupplementEvent>((event, emit) async {
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SupplementFromArguments>((event, emit) async {
      // state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      state.supplementObj = event.supplementSimple;
      // state.isEdit = true;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSupplementInfoUpdateSupplementEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.supplementObj!.info.orEmpty().map((food) => food.id).contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info.orEmpty().indexOf(state.supplementObj!.info.orEmpty().firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info.orEmpty().remove(state.supplementObj!.info.orEmpty()[itemIndex]);
        state.supplementObj!.info?.add(event.nutriInfo);
      } else {
        state.supplementObj!.info?.insert(0, event.nutriInfo);
      }
      emit(state.copyWith(isLoading: false,));
    });

    on<RemoveSupplementInfoUpdateSupplementEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.supplementObj?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info!.indexOf(state.supplementObj!.info!.firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info!.remove(state.supplementObj!.info![itemIndex]);
      }

      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateNameSupplementUpdateSupplementEvent>((event, emit) {
      state.supplementObj?.name = event.name;
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateTimeOfDaySupplementUpdateSupplementEvent>((event, emit) {
      state.supplementObj?.scheduleTime = event.scheduleTime;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateDaysOfWeekSupplementUpdateSupplementEvent>((event, emit) {
      if (state.supplementObj?.daysOfWeek.orEmpty().contains(event.weekDay) ?? false) {
        state.supplementObj?.daysOfWeek?.remove(event.weekDay);
      } else {
        state.supplementObj?.daysOfWeek?.add(event.weekDay);
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateAmountSupplementInfoUpdateSupplementEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.supplementObj!.info.orEmpty().map((food) => food.id).contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info.orEmpty().indexOf(state.supplementObj!.info.orEmpty().firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info?[itemIndex].amount = event.nutriInfo.amount;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<SavingUpdateSupplement>((event, emit) {
      if (state.supplementObj?.isFavorite == true) {
        add(SavingUpdateSupplementFavorite(onFinish: event.onFinish));
      } else if (state.supplementObj?.isRoutine == true) {
        if (state.supplementObj?.daysOfWeek?.isEmpty == true || state.supplementObj?.scheduleTime.isEmptyOrNull() == true) return;
        add(SavingUpdateSupplementRoutine(onFinish: event.onFinish));
      }

    });

    on<SavingUpdateSupplementFavorite>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        state.supplementObj?.userId = getUserIdInteractor.execute();
        state.supplementObj?.eventId = state.supplementObj?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        final uploadSupplementFavorite = mapToSupplementFavoriteFromSupplement(state.supplementObj!);
        await uploadSupplementFavoriteInteractor.execute(uploadSupplementFavorite);
        try {
          await saveSupplementFavoriteInteractor.execute(uploadSupplementFavorite, true);
          _clearData();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false));
        } catch(_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSupplementFavoriteError));
        }
      } catch(_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementFavoriteError));
      }
    });

    on<SavingUpdateSupplementRoutine>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        state.supplementObj?.userId = getUserIdInteractor.execute();
        state.supplementObj?.eventId = state.supplementObj?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.eventDate = state.supplementObj?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
        state.supplementObj?.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
        final uploadSupplementRoutine = mapToSupplementRoutineFromSupplement(state.supplementObj!);
        await uploadSupplementRoutineInteractor.execute(uploadSupplementRoutine);
        try {
          await saveSupplementRoutineInteractor.execute(uploadSupplementRoutine, true);
          _clearData();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false));
        } catch(_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSupplementRoutineError));
        }
      } catch(_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSupplementRoutineError));
      }
    });
  }
  void _clearData() {
    state.supplementObj = SupplementSimple.empty();
  }
}
