// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_recipe_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadRecipeFavorite _$UploadRecipeFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadRecipeFavorite(
      userId: json['userId'] as String?,
      eventDate: json['eventDate'] as int?,
      itemRecipe:
          RecipeMaster.fromJson(json['itemRecipe'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UploadRecipeFavoriteToJson(
        UploadRecipeFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'itemRecipe': instance.itemRecipe.toJson(),
    };
