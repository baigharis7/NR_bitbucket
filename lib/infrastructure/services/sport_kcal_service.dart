import 'dart:convert';

import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

/// Ports the sport-event-amplify Lambda logic to Dart.
///
/// Formula per sport: kcal = METs[intensity] * 0.0175 * userWeight * minutes
class SportKcalCalculationService {
  final ReferenceDatabase _db;

  SportKcalCalculationService(this._db);

  static const _metsConstant = 0.0175;

  /// Computes a fully enriched [SportEventComplete] from a
  /// [SportEventSimple], replicating the sport-event-amplify Lambda.
  Future<SportEventComplete> enrichSportEvent(
    SportEventSimple simple, {
    required double userWeight,
  }) async {
    final List<SportEventInfo> enrichedInfo = [];
    int totalEventKcal = 0;

    for (final sport in simple.info ?? <SportInfo>[]) {
      final sportId = sport.id;
      final intensity = sport.intensity ?? 0;
      final minutes = sport.minutes ?? 0;

      int kcal = 0;
      if (sportId != null) {
        final sportMets = await _db.getSportMets(sportId);
        if (sportMets != null) {
          final metsList = _decodeMets(sportMets.mets);
          final metsValue = (intensity >= 0 && intensity < metsList.length)
              ? metsList[intensity]
              : (metsList.isNotEmpty ? metsList[0] : 0.0);

          kcal = (metsValue * _metsConstant * userWeight * minutes).round();
        }
      }

      totalEventKcal += kcal;

      enrichedInfo.add(SportEventInfo(
        id: sport.id ?? 0,
        name_en: sport.name_en,
        name_es: sport.name_es,
        intensity: sport.intensity,
        minutes: sport.minutes ?? 0,
        timeStart: sport.timeStart,
        kcal: kcal,
      ));
    }

    return SportEventComplete(
      userId: simple.userId ?? '',
      eventId: simple.eventId ?? simple.eventDate ?? 0,
      eventDate: simple.eventDate ?? 0,
      comment: simple.comment,
      sportName: simple.sportName,
      info: enrichedInfo,
      eventKcals: totalEventKcal,
    );
  }

  List<double> _decodeMets(String json) {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((v) => (v is num) ? v.toDouble() : 0.0).toList();
    }
    return [];
  }
}
