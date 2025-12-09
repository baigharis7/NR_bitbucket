import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

import '../../../domain/interactor/eventssync/update_events_interactor.dart';
import '../../../domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/supplements/supplement_simple.dart';

part 'supplements_detail_event.dart';
part 'supplements_detail_state.dart';

class SupplementsDetailBloc extends Bloc<SupplementsDetailEvent, SupplementsDetailState> {
  final GetDaySupplementEventsInteractor getDaySupplementEventsInteractor;
  final DeleteSupplementEventInteractor deleteSupplementEventInteractor;
  final RemoveSupplementEventInteractor removeSupplementEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetProfileInteractor getProfileInteractor;
  final UpdateEventsInteractor updateEventsInteractor;

  SupplementsDetailBloc({
    required this.getDaySupplementEventsInteractor,
    required this.deleteSupplementEventInteractor,
    required this.removeSupplementEventInteractor,
    required this.getMasterFileInteractor,
    required this.getProfileInteractor,
    required this.updateEventsInteractor,
  }) : super(SupplementsDetailState(
    isLoading: false,
    supplementEvents: [],
  ),) {
    on<InitializeSupplementsDetailEvent>((event, emit) async {
      // _clearData();
      emit(state.copyWith(isLoading: true));
      state.eventDate = event.eventDate;
      state.userProfile = await getProfileInteractor.execute();
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      // state.supplemntCreatines = state.supplementEvents.where((item) => item.info?.length == 1 && item.info?[0].id == Constants.CREATINE).toList();
      // state.supplemntCollagens = state.supplementEvents.where((item) => item.info?.length == 1 && item.info?[0].id == Constants.COLLAGEN).toList();
      // state.supplementEvents.removeWhere((item) => item.info?.length == 1 && (item.info?[0].id == Constants.CREATINE || item.info?[0].id == Constants.COLLAGEN));
      add(SummaryInitializeSupplementsDetailEvent());
      emit(state.copyWith(isLoading: false));

      final shouldRefresh = await updateEventsInteractor.execute(userId: state.userProfile?.userId ?? '', categoryType: PrefsKeys.supplementEvents, fullSync: false);
      if (shouldRefresh) {
        add(SummaryInitializeSupplementsDetailEvent());
        emit(state.copyWith(isLoading: false));
      }

    });

    on<SummaryInitializeSupplementsDetailEvent>((event, emit) async {
      state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: state.eventDate);
      state.totalAmountCreatine = state.supplementEvents
          .expand((event) => event.info!)
          .where((info) => info.id == Constants.CREATINE)
          .fold<int>(0, (sum, info) => sum + (info.amount));

      state.totalAmountCollagen = state.supplementEvents
          .expand((event) => event.info!)
          .where((info) => info.id == Constants.COLLAGEN)
          .fold<int>(0, (sum, info) => sum + (info.amount));
    });

    on<UpdateEventsDateSupplementsDetailEvent>((event, emit) async {
      state.eventDate = event.dateTime;
      add(InitializeSupplementsDetailEvent(eventDate: state.eventDate));

      emit(state.copyWith(isLoading: false));
    });

    on<DeleteSupplementEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteSupplementEventInteractor.execute(event.supplement);
        try {
          await removeSupplementEventInteractor.execute(event.supplement);
          add(InitializeSupplementsDetailEvent(eventDate: state.eventDate));
          emit(state.copyWith(isLoading: false,));
        } catch(_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSupplementEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSupplementEventError));
      }

    });

  }

  void _clearData() {
    state.eventDate = DateTime.now();
    state.supplementEvents = [];
  }
}
