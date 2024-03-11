import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';

part 'upload_recipe_favorite.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadRecipeFavorite extends Translatable {
  String? userId;
  int? eventDate;
  RecipeMaster itemRecipe;

  UploadRecipeFavorite({required this.userId, required this.eventDate, required this.itemRecipe});

  factory UploadRecipeFavorite.fromJson(Map<String, dynamic> json) => _$UploadRecipeFavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$UploadRecipeFavoriteToJson(this);
}