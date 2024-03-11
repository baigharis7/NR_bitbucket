import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/recipe_detail/bloc/recipe_detail_bloc.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../widgets/recipe_ingredient.dart';

class RecipeIngredients extends StatefulWidget {
  const RecipeIngredients({super.key});

  @override
  State<RecipeIngredients> createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  late RecipeDetailBloc recipeDetailBloc;
  @override
  void initState() {
    recipeDetailBloc = BlocProvider.of<RecipeDetailBloc>(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: recipeDetailBloc, child: Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<RecipeDetailBloc, RecipeDetailState>(listener: (context, state) {}, builder: (context, state) => SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(Dimens.marginNormal),
          color: Colors.grey[100],
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(width: double.infinity,child: RecipeIngredientItem(name: 'Servings', imageSource: 'assets/images/persons.png', qty: state.uploadRecipeFavorite?.itemRecipe.servings.toString() ?? '', styleText: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
              ),
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: SizedBox(width: double.infinity,child: RecipeIngredientItem(name: 'Calories', imageSource: 'assets/images/persons.png', qty: state.uploadRecipeFavorite?.itemRecipe.servings.toString() ?? '', styleText: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
              // ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ...state.uploadRecipeFavorite?.itemRecipe.ingredients.orEmpty().map((e) {
                    return SizedBox(width: double.infinity,
                    child: RecipeIngredientItem(
                    name: recipeDetailBloc.getFoodNameByFoodId(e.id).translate(context),
                    qty: e.qtyGrams.toString(),
                    ),
                  );}) ?? [], ],
                ),
              ),
            ],
          ),
        ),
      ),),
    ),);
  }
}