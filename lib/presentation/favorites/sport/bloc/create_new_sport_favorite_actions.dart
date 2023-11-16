import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

import '../../../../domain/models/sportevents/sport_event_simple.dart';

class CreateNewSportFavoriteActions {
  CreateNewSportFavoriteActions();
}

class InitializeStateAction extends CreateNewSportFavoriteActions {
  InitializeStateAction();
}

class SetSportIdAction extends CreateNewSportFavoriteActions {
  final int sportId;

  SetSportIdAction({required this.sportId});
}

class SetMinutesAction extends CreateNewSportFavoriteActions {
  final int minutes;

  SetMinutesAction({required this.minutes});
}

class SetIntensityAction extends CreateNewSportFavoriteActions {
  final int intensity;
  final String currentLanguage;

  SetIntensityAction({required this.intensity, required this.currentLanguage});
}

class SetTimeStartAction extends CreateNewSportFavoriteActions {
  final TimeOfDay timeOfDay;

  SetTimeStartAction({required this.timeOfDay});
}

class SetSportFavoriteNameAction extends CreateNewSportFavoriteActions {
  final String favoriteName;

  SetSportFavoriteNameAction({required this.favoriteName});
}

class SetCommentAction extends CreateNewSportFavoriteActions {
  final String comment;

  SetCommentAction({required this.comment});
}

class FinishCreateSportFavoriteAction extends CreateNewSportFavoriteActions {
  final String currentLanguage;
  final Function onFinish;

  FinishCreateSportFavoriteAction({required this.currentLanguage, required this.onFinish});
}

class ResetFavoriteSportInfoAction extends CreateNewSportFavoriteActions {
  ResetFavoriteSportInfoAction();
}

class AddFavSportAction extends CreateNewSportFavoriteActions{
  final SportInfo sportFavInfo;

  AddFavSportAction(this.sportFavInfo);
}