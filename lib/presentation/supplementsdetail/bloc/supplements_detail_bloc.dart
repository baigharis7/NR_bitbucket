import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/supplements/supplement_simple.dart';

part 'supplements_detail_event.dart';
part 'supplements_detail_state.dart';

class SupplementsDetailBloc extends Bloc<SupplementsDetailEvent, SupplementsDetailState> {
  final GetDaySupplementEventsInteractor getDaySupplementEventsInteractor;
  final DeleteSupplementEventInteractor deleteSupplementEventInteractor;
  final RemoveSupplementEventInteractor removeSupplementEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  SupplementsDetailBloc({
    required this.getDaySupplementEventsInteractor,
    required this.deleteSupplementEventInteractor,
    required this.removeSupplementEventInteractor,
    required this.getMasterFileInteractor,
  }) : super(SupplementsDetailState(
    isLoading: false,
    supplementEvents: [],
  ),) {
    on<InitializeSupplementsDetailEvent>((event, emit) async {
      _clearData();
      emit(state.copyWith(isLoading: true));
      state.supplementEvents = await getDaySupplementEventsInteractor.execute();
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateEventsDateSupplementsDetailEvent>((event, emit) async {
      state.eventDate = event.dateTime;
      state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: state.eventDate);

      emit(state.copyWith(isLoading: false));
    });

    on<DeleteSupplementEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteSupplementEventInteractor.execute(event.supplement);
        try {
          await removeSupplementEventInteractor.execute(event.supplement);
          state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: state.eventDate);
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
