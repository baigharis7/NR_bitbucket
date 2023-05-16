import 'package:json_annotation/json_annotation.dart';

part 'water_event_master.g.dart';

@JsonSerializable(explicitToJson: true)
class WaterEventMaster {
  String? userId;
  int? eventDate;
  double? qty;

  WaterEventMaster(
      this.userId,
      this.eventDate,
      this.qty,
  );
  WaterEventMaster.empty({this.userId = '', this.eventDate = 0, this.qty = 0});

  factory WaterEventMaster.fromJson(Map<String, dynamic> json) => _$WaterEventMasterFromJson(json);
  Map<String, dynamic> toJson() => _$WaterEventMasterToJson(this);
}