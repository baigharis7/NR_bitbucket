import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/cooking_methods_oils_info_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_oils_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/master_files_mapper.dart';

void main() {
  group('CookingMethodsOilsInfoResponse', () {
    test('fromJson parses correct JSON structure', () {
      final json = {
        'v': 1,
        'data': [
          {'id': 5, 'name': 'Fried', 'percentage': 10.0},
          {'id': -4, 'name': 'Breaded', 'percentage': 30.0},
        ],
      };

      final response = CookingMethodsOilsInfoResponse.fromJson(json);

      expect(response.v, 1);
      expect(response.data.length, 2);
      expect(response.data[0].id, 5);
      expect(response.data[0].name, 'Fried');
      expect(response.data[0].percentage, 10.0);
      expect(response.data[1].id, -4);
      expect(response.data[1].name, 'Breaded');
      expect(response.data[1].percentage, 30.0);
    });

    test('toJson produces correct structure', () {
      final response = CookingMethodsOilsInfoResponse(
        v: 2,
        data: [
          CookingMethodOilInfoResponse(id: 5, name: 'Fried', percentage: 10.0),
        ],
      );

      final json = response.toJson();

      expect(json['v'], 2);
      expect((json['data'] as List).length, 1);
      expect((json['data'] as List)[0]['id'], 5);
      expect((json['data'] as List)[0]['name'], 'Fried');
      expect((json['data'] as List)[0]['percentage'], 10.0);
    });

    test('fromJson handles integer percentage', () {
      final json = {
        'v': 1,
        'data': [
          {'id': 5, 'name': 'Fried', 'percentage': 10},
        ],
      };

      final response = CookingMethodsOilsInfoResponse.fromJson(json);

      expect(response.data[0].percentage, 10.0);
    });
  });

  group('CookingMethodsOilsInfoEntity', () {
    test('fromJson parses correct JSON structure', () {
      final json = {
        'id': 14,
        'v': 1,
        'data': [
          {'id': 5, 'name': 'Fried', 'percentage': 10.0},
        ],
      };

      final entity = CookingMethodsOilsInfoEntity.fromJson(json);

      expect(entity.id, 14);
      expect(entity.v, 1);
      expect(entity.data.length, 1);
      expect(entity.data[0].id, 5);
      expect(entity.data[0].name, 'Fried');
      expect(entity.data[0].percentage, 10.0);
    });

    test('toJson round-trips correctly', () {
      final entity = CookingMethodsOilsInfoEntity(
        id: 14,
        v: 1,
        data: [
          CookingMethodOilInfoEntity(id: 5, name: 'Fried', percentage: 10.0),
          CookingMethodOilInfoEntity(id: -4, name: 'Breaded', percentage: 30.0),
        ],
      );

      final json = entity.toJson();
      final roundTripped = CookingMethodsOilsInfoEntity.fromJson(json);

      expect(roundTripped.id, entity.id);
      expect(roundTripped.v, entity.v);
      expect(roundTripped.data.length, entity.data.length);
      expect(roundTripped.data[0].id, entity.data[0].id);
      expect(roundTripped.data[1].percentage, entity.data[1].percentage);
    });
  });

  group('mapToCookingMethodsOilsInfoEntity', () {
    test('maps response to entity correctly', () {
      final response = CookingMethodsOilsInfoResponse(
        v: 1,
        data: [
          CookingMethodOilInfoResponse(id: 5, name: 'Fried', percentage: 10.0),
          CookingMethodOilInfoResponse(id: -4, name: 'Breaded', percentage: 30.0),
        ],
      );

      final entity = mapToCookingMethodsOilsInfoEntity(response);

      expect(entity.id, MasterFilesType.cookingMethodsOilsInfo.index);
      expect(entity.v, 1);
      expect(entity.data.length, 2);
      expect(entity.data[0].id, 5);
      expect(entity.data[0].name, 'Fried');
      expect(entity.data[0].percentage, 10.0);
      expect(entity.data[1].id, -4);
      expect(entity.data[1].name, 'Breaded');
      expect(entity.data[1].percentage, 30.0);
    });

    test('mapToMasterFileEntity dispatches to cookingMethodsOilsInfo mapper', () {
      final response = CookingMethodsOilsInfoResponse(
        v: 1,
        data: [
          CookingMethodOilInfoResponse(id: 5, name: 'Fried', percentage: 10.0),
        ],
      );

      final entity = mapToMasterFileEntity(response, MasterFilesType.cookingMethodsOilsInfo);

      expect(entity, isA<CookingMethodsOilsInfoEntity>());
      expect((entity as CookingMethodsOilsInfoEntity).data[0].id, 5);
    });

    test('handles empty data list', () {
      final response = CookingMethodsOilsInfoResponse(v: 1, data: []);

      final entity = mapToCookingMethodsOilsInfoEntity(response);

      expect(entity.data, isEmpty);
      expect(entity.v, 1);
    });
  });
}
