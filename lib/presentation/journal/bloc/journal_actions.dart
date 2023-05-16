class JournalActions {
  JournalActions();
}

class InitializeStateAction extends JournalActions {
  InitializeStateAction();
}

class HideGeneralCardAction extends JournalActions {
  HideGeneralCardAction();
}

class CalendarClickAction extends JournalActions {
  final Function? action;

  CalendarClickAction({required this.action});
}

class HideCalendarCardAction extends JournalActions {
  HideCalendarCardAction();
}

class FoodsClickAction extends JournalActions {
  final Function? action;

  FoodsClickAction({required this.action});
}

class HideFoodsCardAction extends JournalActions {
  HideFoodsCardAction();
}

class SportsClickAction extends JournalActions {
  final Function? action;

  SportsClickAction({required this.action});
}

class HideSportsCardAction extends JournalActions {
  HideSportsCardAction();
}

class LiquidsClickAction extends JournalActions {
  final Function? action;

  LiquidsClickAction({required this.action});
}

class HideLiquidsCardAction extends JournalActions {
  HideLiquidsCardAction();
}
