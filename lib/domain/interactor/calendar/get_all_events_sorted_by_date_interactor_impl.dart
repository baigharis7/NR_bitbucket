import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';

class GetAllEventsSortedByDateInteractorImpl extends GetAllEventsSortedByDateInteractor {
  final CalendarRepository calendarRepository;

  GetAllEventsSortedByDateInteractorImpl({required this.calendarRepository});

  @override
  Future<CalendarEvents> execute() async => await calendarRepository.getAllEvents();

}