import 'package:nutrenaissance_flutter/data/api/recommendations/recommendations_api.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/repository/recommendations/recommendations_repository.dart';

class RecommendationsRepositoryImpl extends RecommendationsRepository {
  final RecommendationsApi recommendationsApi;

  RecommendationsRepositoryImpl({required this.recommendationsApi});

  @override
  Future<Recommendation> getRecommendation(String userId) async {
    final response = await recommendationsApi.getRecommendation(userId);
    return Recommendation.fromJson(response);
  }
}