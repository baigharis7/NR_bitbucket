// import 'package:hive/hive.dart';
// import 'package:json_annotation/json_annotation.dart';
//
// part 'recommendation_entity.g.dart';
//
// // TODO: dejo esta clase entera comentada porque no es seguro que tengan que guardarse las recomendaciones.
// // @HiveType(typeId: 12)
// class RecommendationEntity {
//   List<GroupRecommendation> foodList;
//   List<String> userNutrients;
//
//   RecommendationEntity(this.foodList, this.userNutrients);
//
//   factory RecommendationEntity.fromJson(Map<String, dynamic> json) => _$RecommendationEntityFromJson(json);
//   Map<String, dynamic> toJson() => _$RecommendationEntityToJson(this);
// }
//
// // @HiveType(typeId: 12)
// @JsonSerializable(explicitToJson: true)
// class GroupRecommendation {
//   int recGroup;
//   List<int> foods;
//
//   GroupRecommendation(this.recGroup, this.foods);
//
//   factory GroupRecommendation.fromJson(Map<String, dynamic> json) => _$GroupRecommendationFromJson(json);
//   Map<String, dynamic> toJson() => _$GroupRecommendationToJson(this);
// }