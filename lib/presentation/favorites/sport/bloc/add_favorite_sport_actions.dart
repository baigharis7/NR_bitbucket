import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

class AddFavoriteSportActions {
  AddFavoriteSportActions();
}

class InitializeStateAction extends AddFavoriteSportActions {
  InitializeStateAction();
}

class SetSportFavoriteAction extends AddFavoriteSportActions {
  final SportFavorite sportFavorite;

  SetSportFavoriteAction({required this.sportFavorite});
}

class SetSportFavoriteCommentAction extends AddFavoriteSportActions {
  final String comment;
  final Function onFinish;

  SetSportFavoriteCommentAction({required this.comment, required this.onFinish});
}

class SetSportFavoriteNameAction extends AddFavoriteSportActions {
  final String favoriteName;

  SetSportFavoriteNameAction({required this.favoriteName});
}

class FinishAddingFavoriteAction extends AddFavoriteSportActions {
  final Function onFinish;

  FinishAddingFavoriteAction({required this.onFinish});
}

class UpdateSportCommentAction extends AddFavoriteSportActions {
  Function onFinish;

  UpdateSportCommentAction({required this.onFinish});
}