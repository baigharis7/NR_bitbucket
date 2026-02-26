import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_recent_supplement_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class GetRecentSupplementItemsInteractorImpl extends GetRecentSupplementItemsInteractor {
  final SupplementsRepository supplementsRepository;

  GetRecentSupplementItemsInteractorImpl({required this.supplementsRepository});

  @override
  Future<List<SupplementSimple>> execute() async {
    final events = await supplementsRepository.getRecentSupplementEvents();
    // Already sorted by eventDate descending from local storage
    final Map<String, SupplementSimple> seen = {};
    for (final event in events) {
      final ids = (event.info ?? []).map((s) => s.id).toList()..sort();
      final key = ids.join(',');
      if (!seen.containsKey(key)) {
        seen[key] = event;
      }
    }
    return seen.values.toList();
  }
}
