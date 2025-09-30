import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(explicitToJson: true)
class SupplementSimple {
  String? userId;
  int? eventId;
  int? eventDate;
  List<NutriInfo>? info;

  SupplementSimple({this.userId, this.eventId, this.eventDate, this.info});

  SupplementSimple.empty() {
    info = [];
  }
}

class NutriInfo {
  int id;
  int unit;
  int amount;

  NutriInfo({required this.id, required this.unit, required this.amount});
}