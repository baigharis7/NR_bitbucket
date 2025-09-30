import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/supplements/supplement_simple.dart';

part 'supplements_event.dart';

part 'supplements_state.dart';

class SupplementsBloc extends Bloc<SupplementsEvent, SupplementsState> {
  final GetProfileInteractor getProfileInteractor;

  SupplementsBloc({
    required this.getProfileInteractor,
  }) : super(SupplementsState(isLoading: false, supplementObj: SupplementSimple.empty())) {

    on<InitializationSupplementsAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      state.userProfile = await getProfileInteractor.execute();

      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateDateSupplementsAction>((event, emit) {
      state.supplementObj?.eventDate = event.dateTime.millisecondsSinceEpoch;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSupplementInfoSupplementsAction>((event, emit) {
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

    on<RemoveSupplementInfoSupplementsAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.supplementObj?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.nutriInfo).id)) {
        final itemIndex = state.supplementObj!.info!.indexOf(state.supplementObj!.info!.firstWhere((nutriInfo) => nutriInfo.id == event.nutriInfo.id));
        state.supplementObj!.info!.remove(state.supplementObj!.info![itemIndex]);
      }

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
  }
}
