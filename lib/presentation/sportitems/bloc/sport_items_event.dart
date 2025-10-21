part of 'sport_items_bloc.dart';

// @immutable
abstract class SportItemsEvents {}

class SportItemsInitialization extends SportItemsEvents {}

class UpdateDatetimeSportItemsEvents extends SportItemsEvents {
  final DateTime dateTime;

  UpdateDatetimeSportItemsEvents({required this.dateTime});
}

class DeleteSportItemSportItemsEvents extends SportItemsEvents {
  final SportEventComplete sportEventComplete;

  DeleteSportItemSportItemsEvents({required this.sportEventComplete});
}
