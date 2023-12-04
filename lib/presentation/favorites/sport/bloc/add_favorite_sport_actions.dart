import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

import '../../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../../domain/models/sportevents/sport_event_complete.dart';

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

class SetSportEventAction extends AddFavoriteSportActions {
  final SportEventComplete sportEventComplete;

  SetSportEventAction({required this.sportEventComplete});
}

class SetSportFromFavoriteAction extends AddFavoriteSportActions {
  final AddSportFavorite sportFavorite;

  SetSportFromFavoriteAction({required this.sportFavorite});
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

class UpdateSportCommentEventAction extends AddFavoriteSportActions {
  final String comment;

  UpdateSportCommentEventAction({required this.comment});
}

class FinishSportCommentEventAction extends AddFavoriteSportActions {
  final Function onFinish;

  FinishSportCommentEventAction({required this.onFinish});
}

class FinishFavoriteSportCommentAction extends AddFavoriteSportActions {
  final Function onFinish;

  FinishFavoriteSportCommentAction({required this.onFinish});
}

class RemoveFavoriteAction extends AddFavoriteSportActions {
  final AddSportFavorite sportFavorite;
  final Function onFinish;

  RemoveFavoriteAction({required this.onFinish, required this.sportFavorite});
}