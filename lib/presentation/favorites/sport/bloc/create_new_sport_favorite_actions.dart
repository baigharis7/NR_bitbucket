import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

import '../../../../domain/models/sportevents/sport_event_simple.dart';

class CreateNewSportFavoriteActions {
  CreateNewSportFavoriteActions();
}

class InitializeStateAction extends CreateNewSportFavoriteActions {
  InitializeStateAction();
}

class RemoveSportFavAction extends CreateNewSportFavoriteActions {
  final AddSportFavInfo addSportFavInfo;

  RemoveSportFavAction({required this.addSportFavInfo});
}

class UpdateMinutesSportFavAction extends CreateNewSportFavoriteActions {
  final AddSportFavInfo addSportFavInfo;

  UpdateMinutesSportFavAction({required this.addSportFavInfo});
}

class UpdateIntensitySportFavAction extends CreateNewSportFavoriteActions {
  final AddSportFavInfo addSportFavInfo;

  UpdateIntensitySportFavAction({required this.addSportFavInfo});
}

class UpdateTimeStartSportFavAction extends CreateNewSportFavoriteActions {
  final AddSportFavInfo addSportFavInfo;

  UpdateTimeStartSportFavAction({required this.addSportFavInfo});
}

class UpdateSportFavoriteNameAction extends CreateNewSportFavoriteActions {
  final String favoriteSportName;

  UpdateSportFavoriteNameAction({required this.favoriteSportName});
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
  final AddSportFavInfo addSportFavInfo;

  AddFavSportAction(this.addSportFavInfo);
}

class UpdateCreateRoutineAction extends CreateNewSportFavoriteActions {}

class SetDataFromDetailNaviAction extends CreateNewSportFavoriteActions {
  final AddSportFavorite favoritesSport;

  SetDataFromDetailNaviAction({required this.favoritesSport});
}

class UpdateRoutineHourAction extends CreateNewSportFavoriteActions {
  final TimeOfDay? timeOfDay;

  UpdateRoutineHourAction({required this.timeOfDay});
}

class UpdateRoutineDateAction extends CreateNewSportFavoriteActions {
  final DateTime? dateTime;

  UpdateRoutineDateAction({required this.dateTime});
}

class FinishCreateRoutineAction extends CreateNewSportFavoriteActions {
  final Function onFinish;

  FinishCreateRoutineAction({required this.onFinish});
}

class FinishSportFavWithoutCreateRoutineAction extends CreateNewSportFavoriteActions {
  final Function onFinish;
  final BuildContext context;

  FinishSportFavWithoutCreateRoutineAction({required this.onFinish, required this.context});
}