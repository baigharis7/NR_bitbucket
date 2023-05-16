import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'sport_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class SportFavorite extends Translatable {
  int? id;
  String? name_en;
  String? name_es;
  String? timeStart;
  int? intensity;
  int? minutes;
  int? eventDate;
  String? title;
  String? comment;

  SportFavorite({
    this.id,
    this.name_en,
    this.name_es,
    this.timeStart,
    this.intensity,
    this.minutes,
    this.eventDate,
    this.title,
    this.comment,
  });

  SportFavorite.empty() {
    id = -1;
    name_en = '';
    name_es = '';
    timeStart = '';
    intensity = -1;
    minutes = -1;
    eventDate = -1;
    title = '';
    comment = '';
  }

  factory SportFavorite.fromJson(Map<String, dynamic> json) => _$SportFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$SportFavoriteToJson(this);
}