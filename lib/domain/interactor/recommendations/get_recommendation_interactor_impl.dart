import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/repository/recommendations/recommendations_repository.dart';

class GetRecommendationInteractorImpl extends GetRecommendationInteractor {
  final RecommendationsRepository recommendationsRepository;

  GetRecommendationInteractorImpl({required this.recommendationsRepository});

  @override
  Future<Recommendation> execute(String userId) => recommendationsRepository.getRecommendation(userId);
}