import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_recent_sport_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';

class GetRecentSportItemsInteractorImpl extends GetRecentSportItemsInteractor {
  final SportEventsRepository sportEventsRepository;

  GetRecentSportItemsInteractorImpl({required this.sportEventsRepository});

  @override
  Future<List<AddSportFavorite>> execute() async {
    final events = await sportEventsRepository.getRecentSportEvents();
    // Already sorted by eventDate descending from local storage
    final Map<String, AddSportFavorite> seen = {};
    for (final event in events) {
      final ids = (event.info ?? []).map((s) => s.id ?? 0).toList()..sort();
      final key = ids.join(',');
      if (!seen.containsKey(key)) {
        seen[key] = mapToSportFavoriteFromEventComplete(event);
      }
    }
    return seen.values.toList();
  }
}
