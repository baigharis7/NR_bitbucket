part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? onError;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  List<UploadFeces>? fecesEvents;
  List<UploadFeces>? urineEvents;
  List<UploadFeces>? urineDayEvents;
  List<UploadFeces>? facesDayEvents;
  int? fecesId;
  int? urineId;
  DateTime? fecesDate;
  DateTime? urineDate;
  List<Map<String, dynamic>>? chart14DaysData;
  List<Map<String, dynamic>>? urineChart14DaysData;
  DateTime? calendarDateTime;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.fecesEvents,
    this.urineEvents,
    this.facesDayEvents,
    this.urineDayEvents,
    this.fecesId,
    this.urineId,
    this.fecesDate,
    this.urineDate,
    this.chart14DaysData,
    this.urineChart14DaysData,
    this.calendarDateTime,
  });

  FecesUrineState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<Feces>? fecesList,
    List<Urines>? urinesList,
    List<UploadFeces>? fecesEvents,
    List<UploadFeces>? urineEvents,
    List<UploadFeces>? urineDayEvents,
    List<UploadFeces>? facesDayEvents,
    int? fecesId,
    int? urineId,
    DateTime? fecesDate,
    DateTime? urineDate,
    List<Map<String, dynamic>>? chart14DaysData,
    List<Map<String, dynamic>>? urineChart14DaysData,
    DateTime? calendarDateTime,
  }) {
    return FecesUrineState(
      isLoading: isLoading,
      onError: onError,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      fecesEvents: fecesEvents ?? this.fecesEvents,
      urineEvents: urineEvents ?? this.urineEvents,
      facesDayEvents: facesDayEvents ?? this.facesDayEvents,
      urineDayEvents: urineDayEvents ?? this.urineDayEvents,
      fecesId: fecesId ?? this.fecesId,
      urineId: urineId ?? this.urineId,
      fecesDate: fecesDate ?? this.fecesDate,
      urineDate: urineDate ?? this.urineDate,
      chart14DaysData: chart14DaysData ?? this.chart14DaysData,
      urineChart14DaysData: urineChart14DaysData ?? this.urineChart14DaysData,
      calendarDateTime: calendarDateTime ?? this.calendarDateTime,
    );
  }
}
