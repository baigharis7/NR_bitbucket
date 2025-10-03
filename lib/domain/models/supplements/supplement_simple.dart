import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(explicitToJson: true)
class SupplementSimple {
  String? userId;
  int? eventId;
  int? eventDate;
  List<NutriInfo>? info;
  String? name;
  bool isFavorite;
  bool isRoutine;
  String? scheduleTime;
  List<int>? daysOfWeek;

  SupplementSimple({this.userId, this.eventId, this.eventDate, this.info, this.name, this.isFavorite = false, this.isRoutine = false, this.scheduleTime, this.daysOfWeek});

  SupplementSimple.empty()
      : info = [],
        isFavorite = false,
        isRoutine = false,
        daysOfWeek = [];

}

@JsonSerializable(explicitToJson: true)
class NutriInfo {
  int id;
  String unit;
  int amount;

  NutriInfo({required this.id, required this.unit, required this.amount});
}