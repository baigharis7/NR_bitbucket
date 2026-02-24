import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_oils_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/foods_and_drinks_names_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/master_files_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/nutrients_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/objectives_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/oil_types_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/recommendation_groups_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/sports_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/subjective_analysis_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/supplements_info_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_foods_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/units_info_response.dart';

/// Loads a JSON fixture file from test/fixtures/ and returns the decoded Map.
Map<String, dynamic> loadFixture(String name) {
  final file = File('test/fixtures/$name.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('SupplementsInfoResponse', () {
    late Map<String, dynamic> json;
    late SupplementsInfoResponse response;

    setUp(() {
      json = loadFixture('supplements_info');
      response = SupplementsInfoResponse.fromJson(json);
    });

    test('parses version', () {
      expect(response.v, 1);
    });

    test('parses all items', () {
      expect(response.data.length, 3);
    });

    test('parses snake_case computer_name field', () {
      expect(response.data[0].computerName, 'vitA');
      expect(response.data[1].computerName, 'omega3');
    });

    test('computer_name is null when absent in JSON', () {
      expect(response.data[2].computerName, isNull);
      expect(response.data[2].en, 'Creatine');
    });

    test('parses all standard fields', () {
      final vitA = response.data[0];
      expect(vitA.id, 0);
      expect(vitA.en, 'Vitamin A');
      expect(vitA.es, 'Vitamina A');
      expect(vitA.unit, 'μg');
    });

    test('round-trip: toJson produces correct keys', () {
      final reJson = response.data[0].toJson();
      expect(reJson['computer_name'], 'vitA');
      expect(reJson.containsKey('computerName'), isFalse);
    });
  });

  group('NutrientsInfoResponse', () {
    late NutrientsInfoResponse response;

    setUp(() {
      response = NutrientsInfoResponse.fromJson(loadFixture('nutrients_info'));
    });

    test('parses version and data length', () {
      expect(response.v, 2);
      expect(response.data.length, 2);
    });

    test('parses all fields including nullable ones', () {
      final vitA = response.data[0];
      expect(vitA.officialName, 'vitA');
      expect(vitA.unit, 'μg');
      expect(vitA.name_en, 'Vitamin A');
      expect(vitA.name_es, 'Vitamina A');
      expect(vitA.description_en, 'Essential for vision');
      expect(vitA.foods_en, 'Carrots, spinach');
      expect(vitA.abbr, 'VA');
    });

    test('nullable fields are null when absent', () {
      final calcium = response.data[1];
      expect(calcium.officialName, 'calcium');
      expect(calcium.description_en, isNull);
      expect(calcium.foods_en, isNull);
      expect(calcium.abbr, isNull);
    });
  });

  group('SportsInfoResponse', () {
    late SportsInfoResponse response;

    setUp(() {
      response = SportsInfoResponse.fromJson(loadFixture('sports_info'));
    });

    test('parses version and data', () {
      expect(response.v, 1);
      expect(response.data.length, 2);
    });

    test('parses all fields', () {
      expect(response.data[0].id, 0);
      expect(response.data[0].en, 'Running');
      expect(response.data[0].es, 'Correr');
      expect(response.data[0].mets, 8);
    });
  });

  group('FoodsAndDrinksNamesResponse', () {
    late FoodsAndDrinksNamesResponse response;

    setUp(() {
      response = FoodsAndDrinksNamesResponse.fromJson(
          loadFixture('foods_and_drinks_names'));
    });

    test('parses version', () {
      expect(response.v, 3);
    });

    test('parses nested food names', () {
      expect(response.data.foodNames.length, 2);
      final apple = response.data.foodNames[0];
      expect(apple.id, 100);
      expect(apple.en, 'Apple');
      expect(apple.es, 'Manzana');
      expect(apple.g, 'fruits');
      expect(apple.units, 'piece');
    });

    test('parses nested drink names', () {
      expect(response.data.drinkNames.length, 1);
      expect(response.data.drinkNames[0].en, 'Orange Juice');
    });

    test('nullable units field', () {
      expect(response.data.foodNames[1].units, isNull);
    });
  });

  group('ObjectivesInfoResponse', () {
    late ObjectivesInfoResponse response;

    setUp(() {
      response =
          ObjectivesInfoResponse.fromJson(loadFixture('objectives_info'));
    });

    test('parses all three lists', () {
      expect(response.data.length, 2);
      expect(response.metabolicObjectives.length, 1);
      expect(response.bodyCompositionObjectives.length, 1);
    });

    test('parses objective fields', () {
      expect(response.data[0].id, 0);
      expect(response.data[0].en, 'Lose weight');
      expect(response.data[0].es, 'Perder peso');
    });
  });

  group('CookingMethodsResponse', () {
    late CookingMethodsResponse response;

    setUp(() {
      response =
          CookingMethodsResponse.fromJson(loadFixture('cooking_methods'));
    });

    test('parses groups with method IDs', () {
      expect(response.data.length, 2);
      expect(response.data[0].g, 'dry');
      expect(response.data[0].m, [0, 1, 2]);
      expect(response.data[1].g, 'wet');
      expect(response.data[1].m, [3, 4]);
    });
  });

  group('CookingMethodsInfoResponse', () {
    late CookingMethodsInfoResponse response;

    setUp(() {
      response = CookingMethodsInfoResponse.fromJson(
          loadFixture('cooking_methods_info'));
    });

    test('parses all fields', () {
      expect(response.data.length, 3);
      expect(response.data[0].id, 0);
      expect(response.data[0].en, 'Grilling');
      expect(response.data[0].es, 'A la parrilla');
    });
  });

  group('CookingMethodsOilsInfoResponse', () {
    late CookingMethodsOilsInfoResponse response;

    setUp(() {
      response = CookingMethodsOilsInfoResponse.fromJson(
          loadFixture('cooking_methods_oils_info'));
    });

    test('parses all fields including double', () {
      expect(response.data.length, 2);
      expect(response.data[0].id, 0);
      expect(response.data[0].name, 'Olive Oil');
      expect(response.data[0].percentage, 0.15);
    });
  });

  group('ConversionFactorsResponse', () {
    late ConversionFactorsResponse response;

    setUp(() {
      response = ConversionFactorsResponse.fromJson(
          loadFixture('conversion_factors'));
    });

    test('parses all fields', () {
      expect(response.data.length, 2);
      expect(response.data[0].id, 0);
      expect(response.data[0].en, 'Raw');
      expect(response.data[0].es, 'Crudo');
    });
  });

  group('ConversionFactorsInfoResponse', () {
    late ConversionFactorsInfoResponse response;

    setUp(() {
      response = ConversionFactorsInfoResponse.fromJson(
          loadFixture('conversion_factors_info'));
    });

    test('parses nested list structure', () {
      expect(response.data.length, 1);
      final factor = response.data[0];
      expect(factor.id, 0);
      expect(factor.value, 'weight_loss');
      expect(factor.list.length, 2);
      expect(factor.list[0].g, 'protein');
      expect(factor.list[0].v, 1.2);
    });
  });

  group('UnitsInfoResponse', () {
    late UnitsInfoResponse response;

    setUp(() {
      response = UnitsInfoResponse.fromJson(loadFixture('units_info'));
    });

    test('parses all fields including nullable plurals', () {
      expect(response.data.length, 3);
      expect(response.data[0].en, 'gram');
      expect(response.data[0].enPlural, 'grams');
      expect(response.data[0].esPlural, 'gramos');
    });

    test('nullable plural fields', () {
      expect(response.data[2].enPlural, isNull);
      expect(response.data[2].esPlural, isNull);
    });
  });

  group('UnitsFoodsResponse', () {
    late UnitsFoodsResponse response;

    setUp(() {
      response = UnitsFoodsResponse.fromJson(loadFixture('units_foods'));
    });

    test('parses all fields', () {
      expect(response.data.length, 2);
      expect(response.data[0].id, 100);
      expect(response.data[0].units, 'piece,gram');
    });
  });

  group('RecommendationGroupsResponse', () {
    late RecommendationGroupsResponse response;

    setUp(() {
      response = RecommendationGroupsResponse.fromJson(
          loadFixture('recommendation_groups'));
    });

    test('parses all fields including string list', () {
      expect(response.data.length, 2);
      expect(response.data[0].id, 0);
      expect(response.data[0].groups, ['fruits', 'vegetables']);
      expect(response.data[0].size, 5);
      expect(response.data[0].en, 'Fruits & Vegs');
    });
  });

  group('SubjectiveAnalysisListResponse', () {
    late SubjectiveAnalysisListResponse response;

    setUp(() {
      response = SubjectiveAnalysisListResponse.fromJson(
          loadFixture('subjective_analysis'));
    });

    test('parses all fields', () {
      expect(response.data.length, 2);
      final q1 = response.data[0];
      expect(q1.q_id, 1);
      expect(q1.q_type, 0);
      expect(q1.q_es, '¿Cómo duermes?');
      expect(q1.q_en, 'How do you sleep?');
      expect(q1.obj_id, [0, 1]);
      expect(q1.eval, 'sleep_quality');
    });

    test('nullable answer lists', () {
      expect(response.data[0].ans_en, isNull);
      expect(response.data[0].ans_es, isNotNull);
      expect(response.data[0].ans_es!.length, 1);
    });

    test('parses test question answers', () {
      final answer = response.data[0].ans_es![0];
      expect(answer.id, 0);
      expect(answer.title, 'Calidad del sueño');
      expect(answer.afirm, 'Bien');
      expect(answer.neg, 'Mal');
    });
  });

  group('OilTypesResponse', () {
    late OilTypesResponse response;

    setUp(() {
      response = OilTypesResponse.fromJson(loadFixture('oil_types'));
    });

    test('parses all fields', () {
      expect(response.data.length, 2);
      expect(response.data[0].id, 0);
      expect(response.data[0].en, 'Olive Oil');
      expect(response.data[0].es, 'Aceite de oliva');
    });
  });

  group('MasterFilesResponse (wrapper)', () {
    test('parses with only supplementsInfo present', () {
      final json = {
        'supplementsInfoResponse': loadFixture('supplements_info'),
      };
      final response = MasterFilesResponse.fromJson(json);

      expect(response.supplementsInfoResponse, isNotNull);
      expect(response.supplementsInfoResponse!.data[0].computerName, 'vitA');
      expect(response.cookingMethodsResponse, isNull);
      expect(response.nutrientsInfoResponse, isNull);
    });

    test('parses with all master files present', () {
      final json = {
        'cookingMethodsResponse': loadFixture('cooking_methods'),
        'cookingMethodsInfoResponse': loadFixture('cooking_methods_info'),
        'oilTypesResponse': loadFixture('oil_types'),
        'conversionFactorsResponse': loadFixture('conversion_factors'),
        'conversionFactorsInfoResponse': loadFixture('conversion_factors_info'),
        'nutrientsInfoResponse': loadFixture('nutrients_info'),
        'foodsAndDrinksNamesResponse': loadFixture('foods_and_drinks_names'),
        'objectivesResponse': loadFixture('objectives_info'),
        'recommendationGroupsResponse': loadFixture('recommendation_groups'),
        'sportsInfoResponse': loadFixture('sports_info'),
        'unitsInfoResponse': loadFixture('units_info'),
        'unitsFoodsResponse': loadFixture('units_foods'),
        'supplementsInfoResponse': loadFixture('supplements_info'),
        'subjectiveAnalysisResponse': loadFixture('subjective_analysis'),
        'cookingMethodsOilsInfoResponse':
            loadFixture('cooking_methods_oils_info'),
      };
      final response = MasterFilesResponse.fromJson(json);

      expect(response.cookingMethodsResponse, isNotNull);
      expect(response.cookingMethodsInfoResponse, isNotNull);
      expect(response.oilTypesResponse, isNotNull);
      expect(response.conversionFactorsResponse, isNotNull);
      expect(response.conversionFactorsInfoResponse, isNotNull);
      expect(response.nutrientsInfoResponse, isNotNull);
      expect(response.foodsAndDrinksNamesResponse, isNotNull);
      expect(response.objectivesResponse, isNotNull);
      expect(response.recommendationGroupsResponse, isNotNull);
      expect(response.sportsInfoResponse, isNotNull);
      expect(response.unitsInfoResponse, isNotNull);
      expect(response.unitsFoodsResponse, isNotNull);
      expect(response.supplementsInfoResponse, isNotNull);
      expect(response.subjectiveAnalysisResponse, isNotNull);
      expect(response.cookingMethodsOilsInfoResponse, isNotNull);
    });
  });
}
