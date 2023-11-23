
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