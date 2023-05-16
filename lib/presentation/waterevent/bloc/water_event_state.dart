import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class WaterEventState {
  bool isLoading;
  ErrorTypes? onError;
  WaterEventMaster? waterEventMaster;
  List<double>? waterQuantities;

  WaterEventState({
    required this.isLoading,
    this.onError,
    this.waterEventMaster,
    this.waterQuantities,
  });

  WaterEventState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    WaterEventMaster? waterEventMaster,
    List<double>? waterQuantities,
  }) {
    return WaterEventState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      waterEventMaster: waterEventMaster ?? this.waterEventMaster,
      waterQuantities: waterQuantities ?? this.waterQuantities,
    );
  }

}