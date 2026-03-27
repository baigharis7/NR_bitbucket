import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_mapper_service.dart';

void main() {
  group('NutrientMapperService', () {
    group('mapFromOpenFoodFacts', () {
      test('maps basic macros', () {
        final nutriments = {
          'energy-kcal_100g': 250.0,
          'proteins_100g': 12.0,
          'carbohydrates_100g': 30.0,
          'fat_100g': 10.0,
          'fiber_100g': 3.0,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['energyKcal'], 250.0);
        expect(result['proteinLabel'], 12.0);
        expect(result['carbsAvailable'], 30.0);
        expect(result['fatTotal'], 10.0);
        expect(result['fiber'], 3.0);
      });

      test('maps vitamins and minerals', () {
        final nutriments = {
          'vitamin-a_100g': 0.5,
          'vitamin-c_100g': 30.0,
          'calcium_100g': 120.0,
          'iron_100g': 2.5,
          'sodium_100g': 0.4,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['vitA'], 0.5);
        expect(result['vitC'], 30.0);
        expect(result['calcium'], 120.0);
        expect(result['iron'], 2.5);
        expect(result['sodium'], 0.4);
      });

      test('converts salt to sodium when sodium not present', () {
        final nutriments = {
          'salt_100g': 2.5, // 2.5g salt = 1.0g sodium
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['sodium'], 1.0);
      });

      test('does not convert salt when sodium already present', () {
        final nutriments = {
          'sodium_100g': 0.5,
          'salt_100g': 2.5,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['sodium'], 0.5); // keeps original sodium
      });

      test('duplicates fat subtypes into sum fields', () {
        final nutriments = {
          'saturated-fat_100g': 5.0,
          'monounsaturated-fat_100g': 3.0,
          'polyunsaturated-fat_100g': 2.0,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['saturated'], 5.0);
        expect(result['sumSat'], 5.0);
        expect(result['monounsaturated'], 3.0);
        expect(result['sumMonoUnsat'], 3.0);
        expect(result['polyunsaturated'], 2.0);
        expect(result['sumPolyUnsat'], 2.0);
      });

      test('ignores zero and negative values', () {
        final nutriments = {
          'energy-kcal_100g': 0,
          'proteins_100g': -1.0,
          'fat_100g': 5.0,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result.containsKey('energyKcal'), false);
        expect(result.containsKey('proteinLabel'), false);
        expect(result['fatTotal'], 5.0);
      });

      test('handles integer values', () {
        final nutriments = {
          'energy-kcal_100g': 250, // int, not double
          'proteins_100g': 12,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result['energyKcal'], 250.0);
        expect(result['proteinLabel'], 12.0);
      });

      test('ignores unknown keys', () {
        final nutriments = {
          'some_unknown_key_100g': 99.0,
          'energy-kcal_100g': 200.0,
        };

        final result = NutrientMapperService.mapFromOpenFoodFacts(nutriments);

        expect(result.length, 1);
        expect(result['energyKcal'], 200.0);
      });

      test('returns empty map for empty nutriments', () {
        final result = NutrientMapperService.mapFromOpenFoodFacts({});
        expect(result, isEmpty);
      });
    });

    group('mapFromPassio', () {
      test('maps basic macros', () {
        final passio = {
          'calories': 250.0,
          'protein': 12.0,
          'carbs': 30.0,
          'fat': 10.0,
        };

        final result = NutrientMapperService.mapFromPassio(passio);

        expect(result['energyKcal'], 250.0);
        expect(result['proteinLabel'], 12.0);
        expect(result['carbsAvailable'], 30.0);
        expect(result['fatTotal'], 10.0);
      });

      test('maps vitamins', () {
        final passio = {
          'vitaminA': 0.5,
          'vitaminC': 30.0,
          'vitaminD': 0.01,
        };

        final result = NutrientMapperService.mapFromPassio(passio);

        expect(result['vitA'], 0.5);
        expect(result['vitC'], 30.0);
        expect(result['vitD'], 0.01);
      });

      test('duplicates fat subtypes into sum fields', () {
        final passio = {
          'saturatedFat': 5.0,
          'monounsaturatedFat': 3.0,
          'polyunsaturatedFat': 2.0,
        };

        final result = NutrientMapperService.mapFromPassio(passio);

        expect(result['sumSat'], 5.0);
        expect(result['sumMonoUnsat'], 3.0);
        expect(result['sumPolyUnsat'], 2.0);
      });

      test('ignores zero values', () {
        final passio = {
          'calories': 0.0,
          'protein': 5.0,
        };

        final result = NutrientMapperService.mapFromPassio(passio);

        expect(result.containsKey('energyKcal'), false);
        expect(result['proteinLabel'], 5.0);
      });
    });

    group('mapFromLogMeal', () {
      test('maps basic macros', () {
        final nutritionalInfo = {
          'calories': 250.0,
          'protein': 12.0,
          'total_carbs': 30.0,
          'total_fat': 10.0,
          'fiber': 3.0,
          'sugar': 5.0,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        expect(result['energyKcal'], 250.0);
        expect(result['proteinLabel'], 12.0);
        expect(result['carbsAvailable'], 30.0);
        expect(result['fatTotal'], 10.0);
        expect(result['fiber'], 3.0);
        expect(result['sugarsTotal'], 5.0);
      });

      test('maps vitamins and minerals', () {
        final nutritionalInfo = {
          'vitamin_a': 0.5,
          'vitamin_c': 30.0,
          'calcium': 120.0,
          'iron': 2.5,
          'sodium': 0.4,
          'potassium': 300.0,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        expect(result['vitA'], 0.5);
        expect(result['vitC'], 30.0);
        expect(result['calcium'], 120.0);
        expect(result['iron'], 2.5);
        expect(result['sodium'], 0.4);
        expect(result['potassium'], 300.0);
      });

      test('prefers first key when multiple map to same field', () {
        // 'calories' and 'totalKCal' both map to 'energyKcal'
        final nutritionalInfo = {
          'calories': 200.0,
          'totalKCal': 250.0,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        // putIfAbsent means first key wins
        expect(result['energyKcal'], 200.0);
      });

      test('duplicates fat subtypes into sum fields', () {
        final nutritionalInfo = {
          'saturated_fat': 5.0,
          'monounsaturated_fat': 3.0,
          'polyunsaturated_fat': 2.0,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        expect(result['saturated'], 5.0);
        expect(result['sumSat'], 5.0);
        expect(result['monounsaturated'], 3.0);
        expect(result['sumMonoUnsat'], 3.0);
        expect(result['polyunsaturated'], 2.0);
        expect(result['sumPolyUnsat'], 2.0);
      });

      test('ignores zero and negative values', () {
        final nutritionalInfo = {
          'calories': 0,
          'protein': -1.0,
          'fat': 5.0,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        expect(result.containsKey('energyKcal'), false);
        expect(result.containsKey('proteinLabel'), false);
        expect(result['fatTotal'], 5.0);
      });

      test('handles integer values', () {
        final nutritionalInfo = {
          'calories': 250,
          'protein': 12,
        };

        final result = NutrientMapperService.mapFromLogMeal(nutritionalInfo);

        expect(result['energyKcal'], 250.0);
        expect(result['proteinLabel'], 12.0);
      });

      test('returns empty map for empty input', () {
        final result = NutrientMapperService.mapFromLogMeal({});
        expect(result, isEmpty);
      });
    });

    group('parseServingGrams', () {
      test('parses plain grams', () {
        expect(NutrientMapperService.parseServingGrams('52 g'), 52.0);
        expect(NutrientMapperService.parseServingGrams('52g'), 52.0);
        expect(NutrientMapperService.parseServingGrams('100.5 g'), 100.5);
      });

      test('parses parenthesized grams', () {
        expect(
          NutrientMapperService.parseServingGrams('0.333 PACKAGE (52 g)'),
          52.0,
        );
        expect(
          NutrientMapperService.parseServingGrams('1 serving (150 g)'),
          150.0,
        );
      });

      test('parses ml as grams', () {
        expect(NutrientMapperService.parseServingGrams('250 ml'), 250.0);
      });

      test('returns null for empty/null', () {
        expect(NutrientMapperService.parseServingGrams(null), isNull);
        expect(NutrientMapperService.parseServingGrams(''), isNull);
      });

      test('returns null for unparseable', () {
        expect(NutrientMapperService.parseServingGrams('one serving'), isNull);
      });
    });
  });
}
