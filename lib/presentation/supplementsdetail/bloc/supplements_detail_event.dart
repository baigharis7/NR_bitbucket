part of 'supplements_detail_bloc.dart';

@immutable
abstract class SupplementsDetailEvent {}

class InitializeSupplementsDetailEvent extends SupplementsDetailEvent {}

class UpdateEventsDateSupplementsDetailEvent extends SupplementsDetailEvent {
  final DateTime dateTime;

  UpdateEventsDateSupplementsDetailEvent({required this.dateTime});
}

class DeleteSupplementEventAction extends SupplementsDetailEvent {
  final SupplementSimple supplement;

  DeleteSupplementEventAction({required this.supplement});
}
