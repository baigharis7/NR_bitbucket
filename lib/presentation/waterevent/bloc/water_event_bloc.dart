import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_state.dart';

class WaterEventBloc extends BaseBloc<WaterEventActions, WaterEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final UploadWaterEventInteractor uploadWaterEventInteractor;
  final SaveWaterEventInteractor saveWaterEventInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;

  WaterEventBloc({
    required this.getUserIdInteractor,
    required this.uploadWaterEventInteractor,
    required this.saveWaterEventInteractor,
    required this.getWaterEventsTodayInteractor,
  }) : super(WaterEventState(
    isLoading: false,
    waterEventMaster: WaterEventMaster.empty(),
    waterQuantities: [],
    onError: null,
  ),){
    on<InitializeStateAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null,));
      state.waterEventMaster!.userId = getUserIdInteractor.execute();
      state.waterEventMaster!.eventDate = DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch;
      state.waterQuantities = EventsHelper().generateWaterQuantities();
      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<ChooseWaterQuantityAction>((event, emit) {
      state.waterEventMaster!.qty = event.qty;
      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<FinishWaterEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));

      try {
        final uploadSuccess = await uploadWaterEventInteractor.execute(state.waterEventMaster!);
        if (uploadSuccess) {
          try {
            saveWaterEventInteractor.execute(state.waterEventMaster!);
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.locallySavingWaterEventError));
          }
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingWaterEventError));
      }
    });

    on<ResetStateAction>((event, emit) {
      state.waterEventMaster = WaterEventMaster.empty();
      emit(state.copyWith(isLoading: false, onError: null));
    });
  }
  
}