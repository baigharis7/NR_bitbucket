import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

abstract class GetDaySupplementEventsInteractor {
  Future<List<SupplementSimple>> execute({DateTime? dateTime});
}