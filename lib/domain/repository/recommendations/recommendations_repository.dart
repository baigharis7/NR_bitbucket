import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';

abstract class RecommendationsRepository {
  Future<Recommendation> getRecommendation(String userId);
}