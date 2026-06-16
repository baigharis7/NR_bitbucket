import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';

void main() {
  // Regression tests for the firstWhere-without-orElse crashes documented in
  // crash_analysis.md (group 2, sports). These sport-lookup methods used to
  // throw StateError when a sport name/id from the server catalog didn't match
  // the local one (or the master list was empty), crashing the sport flows for
  // all users on a catalog update.
  late EventsHelper helper;

  setUp(() => helper = EventsHelper());

  SportsInfoMaster sportsInfoWith(List<SportInfoMaster> sports) =>
      SportsInfoMaster(sportsInfoMaster: sports);

  final running = SportInfoMaster(id: 7, en: 'Running', es: 'Correr', mets: 8);

  group('getSportIdByName', () {
    test('returns the matching id when the sport exists', () {
      final result = helper.getSportIdByName(
          'Running', sportsInfoWith([running]), 'en');
      expect(result, 7);
    });

    test('returns 0 without throwing when there is no match', () {
      final result = helper.getSportIdByName(
          'Swimming', sportsInfoWith([running]), 'en');
      expect(result, 0);
    });

    test('returns 0 without throwing when the master list is empty', () {
      final result =
          helper.getSportIdByName('Running', sportsInfoWith([]), 'en');
      expect(result, 0);
    });

    test('matches by spanish name when language is es', () {
      final result = helper.getSportIdByName(
          'Correr', sportsInfoWith([running]), 'es');
      expect(result, 7);
    });
  });

  group('getChosenSportIntensities', () {
    test('returns the matching mets when the sport exists', () {
      final result = helper.getChosenSportIntensities(
          'Running', sportsInfoWith([running]), 'en');
      expect(result, 8);
    });

    test('returns null when the sport name is null', () {
      final result = helper.getChosenSportIntensities(
          null, sportsInfoWith([running]), 'en');
      expect(result, isNull);
    });

    test('returns null when the master list is empty', () {
      final result = helper.getChosenSportIntensities(
          'Running', sportsInfoWith([]), 'en');
      expect(result, isNull);
    });

    test('returns 0 without throwing when there is no match', () {
      final result = helper.getChosenSportIntensities(
          'Swimming', sportsInfoWith([running]), 'en');
      expect(result, 0);
    });
  });

  group('getSportNameById', () {
    test('returns the matching sport when the id exists', () {
      final result = helper.getSportNameById(7, [running]);
      expect(result.id, 7);
      expect(result.en, 'Running');
    });

    test('returns empty without throwing when there is no match', () {
      final result = helper.getSportNameById(99, [running]);
      expect(result.id, 0);
      expect(result.en, '');
    });

    test('returns empty without throwing when the list is empty', () {
      final result = helper.getSportNameById(7, []);
      expect(result.id, 0);
    });
  });
}
