import 'package:flutter/material.dart';

class RecommendationsActions {
  RecommendationsActions();
}

class InitialStateAction extends RecommendationsActions {
  final BuildContext context;
  InitialStateAction({required this.context});
}

class EmptyRecommendationAction extends RecommendationsActions {
  EmptyRecommendationAction();
}

class ManageFoodToListAction extends RecommendationsActions {
  final int id;

  ManageFoodToListAction({required this.id});
}

class HideExplainingCardAction extends RecommendationsActions {
  HideExplainingCardAction();
}
