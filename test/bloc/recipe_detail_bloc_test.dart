import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/recipe_detail/bloc/recipe_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

RecipeMaster _stubRecipe({double id = 1.0, List<int> meal = const [0]}) {
  return RecipeMaster(
    id: id,
    meal: meal,
    name_es: 'Receta',
    name_en: 'Recipe',
    ingredients: [],
    steps_es: null,
    steps_en: null,
    time: 30,
    difficulty: null,
    servings: 2,
    source: null,
    exclusions: null,
  );
}

void main() {
  late MockGetMasterFileInteractor mockGetMasterFile;

  setUp(() {
    mockGetMasterFile = MockGetMasterFileInteractor();
  });

  RecipeDetailBloc buildBloc() => RecipeDetailBloc(
        getMasterFileInteractor: mockGetMasterFile,
      );

  group('RecipeDetailBloc - InitializationRecipeDetailEventAction', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'loads food + drink names from master file and combines them',
      build: () {
        when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
            .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
                  FoodsAndDrinkListsMaster(
                    foodNames: [FoodItemMaster(id: 1, en: 'Apple', es: 'Manzana')],
                    drinkNames: [FoodItemMaster(id: 100, en: 'Water', es: 'Agua')],
                  ),
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializationRecipeDetailEventAction()),
      verify: (bloc) {
        // Combined list should have both food and drinks
        expect(bloc.state.foodAndDrinksNames, isNotNull);
        expect(bloc.state.foodAndDrinksNames!.length, 2);
        expect(
          bloc.state.foodAndDrinksNames!.map((f) => f.id),
          containsAll([1, 100]),
        );
      },
    );
  });

  group('RecipeDetailBloc - UpdateDataFromDiscoverScreenEventAction', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'wraps the recipe in an UploadRecipeFavorite with null userId/eventDate',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateDataFromDiscoverScreenEventAction(
        recipeMaster: _stubRecipe(id: 42, meal: [0, 2]),
      )),
      verify: (bloc) {
        expect(bloc.state.uploadRecipeFavorite, isNotNull);
        expect(bloc.state.uploadRecipeFavorite!.userId, isNull);
        expect(bloc.state.uploadRecipeFavorite!.eventDate, isNull);
        expect(bloc.state.uploadRecipeFavorite!.itemRecipe.id, 42);
        expect(bloc.state.uploadRecipeFavorite!.itemRecipe.meal, [0, 2]);
      },
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'emits loading then loaded states',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateDataFromDiscoverScreenEventAction(
        recipeMaster: _stubRecipe(),
      )),
      expect: () => [
        isA<RecipeDetailState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RecipeDetailState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });

  group('RecipeDetailBloc - UpdateDateFromRecipeFavoriteScreen', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'sets the uploadRecipeFavorite from the saved favorite',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateDateFromRecipeFavoriteScreen(
        uploadRecipeFavorite: UploadRecipeFavorite(
          userId: 'user123',
          eventDate: 1700000000000,
          itemRecipe: _stubRecipe(id: 7),
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.uploadRecipeFavorite, isNotNull);
        expect(bloc.state.uploadRecipeFavorite!.userId, 'user123');
        expect(bloc.state.uploadRecipeFavorite!.eventDate, 1700000000000);
        expect(bloc.state.uploadRecipeFavorite!.itemRecipe.id, 7);
      },
    );
  });

  group('RecipeDetailBloc - getFoodNameByFoodId', () {
    test('returns the matching FoodItemMaster when id exists', () async {
      when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
          .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
                FoodsAndDrinkListsMaster(
                  foodNames: [FoodItemMaster(id: 5, en: 'Banana', es: 'Plátano')],
                  drinkNames: [],
                ),
              ));
      final bloc = buildBloc();
      bloc.add(InitializationRecipeDetailEventAction());
      await pumpEventQueue();

      final result = bloc.getFoodNameByFoodId(5);
      expect(result.id, 5);
      expect(result.en, 'Banana');
      await bloc.close();
    });

    test('returns FoodItemMaster.empty() when id does not exist', () async {
      when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
          .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
                FoodsAndDrinkListsMaster(
                  foodNames: [FoodItemMaster(id: 5, en: 'Banana', es: 'Plátano')],
                  drinkNames: [],
                ),
              ));
      final bloc = buildBloc();
      bloc.add(InitializationRecipeDetailEventAction());
      await pumpEventQueue();

      final result = bloc.getFoodNameByFoodId(9999);
      expect(result.id, 0);
      expect(result.en, '');
      await bloc.close();
    });

    test('returns FoodItemMaster.empty() when foodAndDrinksNames is null',
        () async {
      final bloc = buildBloc();
      // No InitializationRecipeDetailEventAction triggered, so foodAndDrinksNames is null

      final result = bloc.getFoodNameByFoodId(5);
      expect(result.id, 0);
      expect(result.en, '');
      await bloc.close();
    });
  });
}
