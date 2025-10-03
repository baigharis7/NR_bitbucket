import 'package:json_annotation/json_annotation.dart';

part 'supplement_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class SupplementFavorite {
  String userId;
  int eventId;
  int eventDate;
  List<SupplementFavoriteNutrient> data;
  String name;

  SupplementFavorite({required this.userId, required this.eventId, required this.eventDate, required this.data, required this.name});

  factory SupplementFavorite.fromJson(Map<String, dynamic> json) => _$SupplementFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementFavoriteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SupplementFavoriteNutrient {
  int id;
  int amount;
  String unit;

  SupplementFavoriteNutrient({required this.id, required this.amount, required this.unit});

  factory SupplementFavoriteNutrient.fromJson(Map<String, dynamic> json) => _$SupplementFavoriteNutrientFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementFavoriteNutrientToJson(this);
}