import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../widgets/recipe_ingredient.dart';

class RecipeIngredients extends StatefulWidget {
  const RecipeIngredients({super.key});

  @override
  State<RecipeIngredients> createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(Dimens.marginNormal),
          color: Colors.grey[100],
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: ['1'].map((e) => SizedBox(width: double.infinity,child: RecipeIngredientItem(foodName: e, imageSource: 'assets/images/persons.png', qty: '3',))).toList(),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: ['2','3','4','5'].map((e) => SizedBox(width: double.infinity,child: RecipeIngredientItem(foodName: e, imageSource: 'assets/images/persons.png', qty: '4',))).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}