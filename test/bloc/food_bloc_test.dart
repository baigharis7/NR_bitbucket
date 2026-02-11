import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/presentation/food/bloc/food_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetMasterFileInteractor mockGetMasterFile;

  setUp(() {
    mockGetMasterFile = MockGetMasterFileInteractor();
  });

  FoodsAndDrinksNamesMaster _testFoodData() {
    return FoodsAndDrinksNamesMaster(
      FoodsAndDrinkListsMaster(
        foodNames: [
          FoodItemMaster(id: 1, en: 'Chicken', es: 'Pollo'),
          FoodItemMaster(id: 2, en: 'Chickpea', es: 'Garbanzo'),
          FoodItemMaster(id: 3, en: 'Rice', es: 'Arroz'),
          FoodItemMaster(id: 4, en: 'Salmon', es: 'Salmon'),
        ],
        drinkNames: [],
      ),
    );
  }

  group('FoodBloc', () {
    blocTest<FoodBloc, FoodEventState>(
      'initial state has empty filteredFood',
      build: () => FoodBloc(getMasterFileInteractor: mockGetMasterFile),
      verify: (bloc) {
        expect(bloc.state.filteredFood, isEmpty);
        expect(bloc.state.foodNames!.foodsAndDrinksNames!.foodNames, isEmpty);
      },
    );

    blocTest<FoodBloc, FoodEventState>(
      'InitializeStateEventAction calls interactor when foodNames is empty',
      build: () {
        when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
            .thenAnswer((_) async => _testFoodData());
        return FoodBloc(getMasterFileInteractor: mockGetMasterFile);
      },
      act: (bloc) => bloc.add(InitializeStateEventAction()),
      verify: (bloc) {
        verify(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
            .called(1);
      },
    );

    blocTest<FoodBloc, FoodEventState>(
      'OnChangeEditTextStateAction filters matching food names',
      seed: () => FoodEventState(
        foodNames: _testFoodData(),
        filteredFood: [],
      ),
      build: () => FoodBloc(getMasterFileInteractor: mockGetMasterFile),
      act: (bloc) => bloc.add(OnChangeEditTextStateAction('chick')),
      expect: () => [
        isA<FoodEventState>()
            .having((s) => s.filteredFood?.length, 'count', 2)
            .having((s) => s.filteredFood?.first.en, 'first', 'Chicken')
            .having((s) => s.filteredFood?.last.en, 'last', 'Chickpea'),
      ],
    );

    blocTest<FoodBloc, FoodEventState>(
      'OnChangeEditTextStateAction with empty string returns empty list',
      seed: () => FoodEventState(
        foodNames: _testFoodData(),
        filteredFood: [FoodItemMaster(id: 1, en: 'Chicken')],
      ),
      build: () => FoodBloc(getMasterFileInteractor: mockGetMasterFile),
      act: (bloc) => bloc.add(OnChangeEditTextStateAction('')),
      expect: () => [
        isA<FoodEventState>()
            .having((s) => s.filteredFood, 'filteredFood', isEmpty),
      ],
    );

    blocTest<FoodBloc, FoodEventState>(
      'filter is case-insensitive',
      seed: () => FoodEventState(
        foodNames: _testFoodData(),
        filteredFood: [],
      ),
      build: () => FoodBloc(getMasterFileInteractor: mockGetMasterFile),
      act: (bloc) => bloc.add(OnChangeEditTextStateAction('SALMON')),
      expect: () => [
        isA<FoodEventState>()
            .having((s) => s.filteredFood?.length, 'count', 1)
            .having((s) => s.filteredFood?.first.en, 'name', 'Salmon'),
      ],
    );
  });
}
