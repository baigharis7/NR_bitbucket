import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/sports_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_foods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_info_response.dart';

part 'master_files_response.g.dart';

@JsonSerializable(explicitToJson: true)
class MasterFilesResponse {
  CookingMethodsResponse? cookingMethodsResponse;
  CookingMethodsInfoResponse? cookingMethodsInfoResponse;
  NutrientsInfoResponse? nutrientsInfoResponse;
  FoodsAndDrinksNamesResponse? foodsAndDrinksNamesResponse;
  ObjectivesInfoResponse? objectivesResponse;
  RecommendationGroupsResponse? recommendationGroupsResponse;
  SportsInfoResponse? sportsInfoResponse;
  UnitsInfoResponse? unitsInfoResponse;
  UnitsFoodsResponse? unitsFoodsResponse;
  SubjectiveAnalysisListResponse? subjectiveAnalysisResponse;

  MasterFilesResponse(
      {
        this.cookingMethodsResponse,
        this.cookingMethodsInfoResponse,
        this.nutrientsInfoResponse,
        this.foodsAndDrinksNamesResponse,
        this.objectivesResponse,
        this.recommendationGroupsResponse,
        this.sportsInfoResponse,
        this.unitsInfoResponse,
        this.unitsFoodsResponse,
        this.subjectiveAnalysisResponse,
      }
  );

  factory MasterFilesResponse.fromJson(Map<String, dynamic> json) => _$MasterFilesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MasterFilesResponseToJson(this);
}