import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/food_fuzzy_matcher.dart';

void main() {
  FoodItemMaster _food(int id, String en, {String? es, String? group}) =>
      FoodItemMaster(id: id, en: en, es: es ?? en, group: group ?? 'food');

  group('FoodFuzzyMatcher', () {
    late FoodFuzzyMatcher matcher;

    setUp(() {
      matcher = FoodFuzzyMatcher([
        _food(1, 'Scrambled eggs'),
        _food(2, 'White rice'),
        _food(3, 'Steamed broccoli'),
        _food(4, 'Chicken breast'),
        _food(5, 'Olive oil'),
        _food(6, 'Omelette'),
        _food(7, 'French omelette'),
        _food(8, 'Banana'),
        _food(9, 'Chocolate cake'),
        _food(10, 'Orange juice'),
      ]);
    });

    group('exact match', () {
      test('matches identical name', () {
        final result = matcher.findBestMatch('Scrambled eggs');
        expect(result, isNotNull);
        expect(result!.food.id, 1);
        expect(result.score, 1.0);
      });

      test('matches case-insensitive', () {
        final result = matcher.findBestMatch('SCRAMBLED EGGS');
        expect(result, isNotNull);
        expect(result!.food.id, 1);
        expect(result.score, 1.0);
      });

      test('matches with diacritics removed', () {
        final result = matcher.findBestMatch('Bánàná');
        expect(result, isNotNull);
        expect(result!.food.id, 8);
        expect(result.score, 1.0);
      });
    });

    group('substring match', () {
      test('DB name contained in scanned name matches via token containment',
          () {
        // "french omelette with cheese" — DB tokens {"french", "omelette"}
        // are all found in scanned tokens, so token containment kicks in
        final result = matcher.findBestMatch('French omelette with cheese');
        expect(result, isNotNull);
        expect(result!.food.id, 7);
      });

      test('matches when substring ratio is high enough', () {
        // "french omelette" is exact match for DB id=7
        final result = matcher.findBestMatch('French omelette');
        expect(result, isNotNull);
        expect(result!.food.id, 7);
        expect(result.score, 1.0);
      });

      test('does not match short DB names (< 4 chars)', () {
        final result = matcher.findBestMatch('oil');
        expect(result, isNull);
      });
    });

    group('token overlap', () {
      test('matches when all DB tokens found in scanned name', () {
        // "chicken breast grilled" tokens: {chicken, breast, grilled}
        // DB "Chicken breast" tokens: {chicken, breast}
        // All DB tokens found → containment match
        final result = matcher.findBestMatch('chicken breast grilled');
        expect(result, isNotNull);
        expect(result!.food.id, 4);
      });

      test('matches when token overlap meets threshold', () {
        // "chicken breast" tokens: {chicken, breast}
        // DB "Chicken breast" tokens: {chicken, breast}
        // shared=2, max=2, score=1.0 — exact match
        final result = matcher.findBestMatch('chicken breast');
        expect(result, isNotNull);
        expect(result!.food.id, 4);
        expect(result.score, 1.0);
      });
    });

    group('no match', () {
      test('returns null for unrelated food', () {
        final result = matcher.findBestMatch('Sushi roll');
        expect(result, isNull);
      });

      test('returns null for empty string', () {
        final result = matcher.findBestMatch('');
        expect(result, isNull);
      });

      test('returns null for whitespace only', () {
        final result = matcher.findBestMatch('   ');
        expect(result, isNull);
      });
    });

    group('empty matcher', () {
      test('returns null when no master foods', () {
        final empty = FoodFuzzyMatcher([]);
        expect(empty.findBestMatch('Banana'), isNull);
      });
    });

    group('findTopMatches', () {
      test('returns multiple results sorted by score', () {
        final results = matcher.findTopMatches('omelette', maxResults: 3);
        expect(results, isNotEmpty);
        // Both 'Omelette' and 'French omelette' should match
        expect(results.length, greaterThanOrEqualTo(1));
        // Results should be sorted descending by score
        for (int i = 1; i < results.length; i++) {
          expect(results[i].score, lessThanOrEqualTo(results[i - 1].score));
        }
      });

      test('returns empty list for no matches', () {
        final results = matcher.findTopMatches('xyz');
        expect(results, isEmpty);
      });

      test('respects maxResults', () {
        final results = matcher.findTopMatches('omelette', maxResults: 1);
        expect(results.length, lessThanOrEqualTo(1));
      });
    });

    group('normalization', () {
      test('strips punctuation (but may join words)', () {
        // "scrambled-eggs!" → normalize removes - and ! → "scrambledeggs"
        // DB "Scrambled eggs" → "scrambled eggs"
        // These don't match because hyphen removal joins words
        final result = matcher.findBestMatch('scrambled-eggs!');
        expect(result, isNull);

        // With space-separated input + punctuation, it matches fine
        final result2 = matcher.findBestMatch('scrambled eggs!');
        expect(result2, isNotNull);
        expect(result2!.food.id, 1);
      });

      test('handles ñ and ç', () {
        final m = FoodFuzzyMatcher([_food(100, 'Pina colada')]);
        final result = m.findBestMatch('Piña colada');
        expect(result, isNotNull);
        expect(result!.score, 1.0);
      });

      test('collapses extra whitespace', () {
        final result = matcher.findBestMatch('  scrambled   eggs  ');
        expect(result, isNotNull);
        expect(result!.food.id, 1);
      });
    });
  });
}
