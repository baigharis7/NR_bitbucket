part of 'upload_recipe_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadRecipeFavorite _$UploadRecipeFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadRecipeFavorite(
      userId: json['userId'],
      eventDate: int.parse(json['eventDate']),
      itemRecipe: RecipeMaster.fromJson(json['itemRecipe']),
    );

Map<String, dynamic> _$UploadRecipeFavoriteToJson(
        UploadRecipeFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'itemRecipe': instance.itemRecipe,
    };
