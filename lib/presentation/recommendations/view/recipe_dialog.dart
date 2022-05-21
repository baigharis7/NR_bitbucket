import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RecipeDialog extends StatelessWidget {
  final List<String> ingredientsList;

  const RecipeDialog({Key? key, required this.ingredientsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Image.asset('assets/images/dummy_recipe.jpeg'),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(Dimens.marginLarge),
                  child: const Text(
                    'Recipe name',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimens.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: Dimens.marginSmall, top: Dimens.marginNormal),
                child: const Text(
                    'Ingredients:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontSizeLarge
                  ),
                ),
            ),
            Column(
              children: [
                ...ingredientsList.map((ingredientName) => Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginXSmall),
                  child: Text('$ingredientName, 200gr.'),))
              ],
            ), // TODO: aquí mostraría los ingredientes.
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: Dimens.marginSmall, top: Dimens.marginNormal),
              child: const Text(
                'Preparation:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontSizeLarge
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginXSmall),
                  child: const Text('Paso 1: ...'),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginXSmall),
                  child: const Text('Paso 2: ...'),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginXSmall),
                  child: const Text('Paso 3: ...'),
                ),
              ],
            )
          ],
        ),
      ]
    );
  }

}