import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'add_sport_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class AddSportFavorite extends Translatable {
  String? userId;
  int? eventId;
  int? eventDate;
  String? comment;
  String? title;
  List<AddSportFavInfo>? info;
  String? scheduleTime;
  List<int>? daysOfWeek;


  AddSportFavorite({
    this.userId,
    this.eventId,
    this.eventDate,
    this.comment,
    this.title,
    this.info,
    this.scheduleTime,
    this.daysOfWeek,
  });

  factory AddSportFavorite.fromJson(Map<String, dynamic> json) => _$AddSportFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$AddSportFavoriteToJson(this);

  AddSportFavorite.empty() {
    info = [];
    daysOfWeek = [];
  }
}

@JsonSerializable(explicitToJson: true)
class AddSportFavInfo extends Translatable {
  int? id;
  String? name_en;
  String? name_es;
  int? timeStart;
  int? intensity;
  int? minutes;

  AddSportFavInfo({
    this.id,
    this.name_en,
    this.name_es,
    this.timeStart,
    this.intensity,
    this.minutes,
  });

  factory AddSportFavInfo.fromJson(Map<String, dynamic> json) => _$AddSportFavInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AddSportFavInfoToJson(this);

}