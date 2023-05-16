import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';

abstract class GetRecommendationInteractor {
  Future<Recommendation> execute(String userId);
}