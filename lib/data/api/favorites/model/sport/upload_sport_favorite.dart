import 'package:json_annotation/json_annotation.dart';

part 'upload_sport_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadSportFavorite {
  String userId;
  int? id;
  String? name_en;
  String? name_es;
  String? timeStart;
  int? intensity;
  int? minutes;
  int? eventDate;
  String? title;
  String? comment;

  UploadSportFavorite({
    required this.userId,
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

  factory UploadSportFavorite.fromJson(Map<String, dynamic> json) => _$UploadSportFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSportFavoriteToJson(this);

}