
import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class JournalSportActions {
  JournalSportActions();
}

class InitializeStateAction extends JournalSportActions {
  InitializeStateAction();
}

class HideExplainingCardAction extends JournalSportActions {
  HideExplainingCardAction();
}

class AddSportFavNameAction extends JournalSportActions {
  final String sportFavName;

  AddSportFavNameAction({required this.sportFavName});
}

class FinishAddSportToFavoriteAction extends JournalSportActions {
  final Function onFinish;
  final SportEventComplete sportEvent;

  FinishAddSportToFavoriteAction({required this.onFinish, required this.sportEvent});
}

class RemoveFavoriteSportAction extends JournalSportActions {
  final AddSportFavorite? sportFavorite;
  final Function onFinish;

  RemoveFavoriteSportAction({required this.onFinish, required this.sportFavorite});
}

class DeleteSportEventAction extends JournalSportActions {
  final SportEventComplete sportEventComplete;
  final Function onFinish;

  DeleteSportEventAction({required this.sportEventComplete, required this.onFinish});
}