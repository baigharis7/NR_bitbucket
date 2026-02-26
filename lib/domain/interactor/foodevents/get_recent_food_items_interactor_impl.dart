import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';

class GetRecentFoodItemsInteractorImpl extends GetRecentFoodItemsInteractor {
  final FoodEventsRepository foodEventsRepository;

  GetRecentFoodItemsInteractorImpl({required this.foodEventsRepository});

  @override
  Future<List<FoodFavorite>> execute() async {
    final events = await foodEventsRepository.getRecentFoodEvents();
    // Already sorted by eventDate descending from local storage
    final Map<String, FoodFavorite> seen = {};
    for (final event in events) {
      final ids = (event.foodInfo ?? []).map((f) => f.id ?? 0).toList()..sort();
      final key = '${event.mealType}_${ids.join(',')}';
      if (!seen.containsKey(key)) {
        seen[key] = mapToFoodFavoriteFromFoodEvent(event);
      }
    }
    return seen.values.toList();
  }
}
