import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/interactor/waterevents/save_water_event_interactor.dart';
import '../../../domain/interactor/waterevents/upload_water_event_interactor.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/watervents/water_event_master.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'liquid_summary_detail_event.dart';
part 'liquid_summary_detail_state.dart';

class LiquidSummaryDetailBloc extends Bloc<LiquidSummaryDetailEvent, LiquidSummaryDetailState> {
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final UploadWaterEventInteractor uploadWaterEventInteractor;
  final SaveWaterEventInteractor saveWaterEventInteractor;
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  LiquidSummaryDetailBloc({
    required this.getLiquidEventsOfTodayInteractor,
    required this.getProfileInteractor,
    required this.getUserIdInteractor,
    required this.uploadWaterEventInteractor,
    required this.saveWaterEventInteractor,
    required this.getFoodEventsOfTodayInteractor,
    required this.getWaterEventsTodayInteractor,
  }) : super(LiquidSummaryDetailState(isLoading: false)) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.liquid || category == DataChangedCategory.water) {
        add(LoadLiquidSummaryEventAction());
      }
    });
    on<LoadLiquidSummaryEventAction>((event, emit) async {
      // state.waterEvents = event.waterEvents;
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute();
      state.userProfile = await getProfileInteractor.execute();
      state.todayFoodEvents = await getFoodEventsOfTodayInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<FinishWaterEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));

      final waterEventMaster = WaterEventMaster(
        getUserIdInteractor.execute(),
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        event.qty,
      );

      try {
        final uploadSuccess = await uploadWaterEventInteractor.execute(waterEventMaster);
        if (uploadSuccess) {
          try {
            saveWaterEventInteractor.execute(waterEventMaster);
            DashboardEventBus.instance.notify(DataChangedCategory.water);
            state.waterEvents = await getWaterEventsTodayInteractor.execute();
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
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}
