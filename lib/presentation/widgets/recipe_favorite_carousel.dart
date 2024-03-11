import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recipe_card.dart';

import '../../domain/models/masterfiles/food_names_master.dart';
import '../../domain/models/recipes/upload_recipe_favorite.dart';

class RecipeFavoriteCarousel extends StatefulWidget {
  final String mealTime;
  final List<UploadRecipeFavorite> recipesFavorites;
  final List<String> imagesList;
  final List<FoodItemMaster> Function(List<RecipeIngredient> ingredients) getIngredients;
  final Function(UploadRecipeFavorite itemRecipe) screenToMove;
  final Function(RecipeMaster itemRecipe) heartClick;
  final Function(UploadRecipeFavorite uploadRecipeFavorite) deleteItemRecipe;

  const RecipeFavoriteCarousel({
    Key? key,
    required this.mealTime,
    required this.recipesFavorites,
    required this.imagesList,
    required this.getIngredients,
    required this.screenToMove,
    required this.heartClick,
    required this.deleteItemRecipe,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecipeFavoriteCarousel();
}

class _RecipeFavoriteCarousel extends State<RecipeFavoriteCarousel> {
  final _pageController = PageController(initialPage: 0);
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: Dimens.marginSmall, right: Dimens.marginSmall, top: Dimens.marginLarge, bottom: Dimens.marginXSmall),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.mealTime.appendColon(),
                style: const TextStyle(
                  fontSize: Dimens.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (widget.recipesFavorites.orEmpty().length > 1 && _activePage != 0) IconButton(
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 500), curve:Curves.easeIn),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      final itemRecipe = widget.recipesFavorites[index];
                      return RecipeCard(
                        recipeMaster: itemRecipe.itemRecipe,
                        ingredientsNames: widget.getIngredients.call(itemRecipe.itemRecipe.ingredients),
                        image: widget.imagesList[index],
                        screenToMove: () => widget.screenToMove.call(itemRecipe),
                        heartClick: () => widget.heartClick.call(itemRecipe.itemRecipe),
                        isFavorite: true,
                        ondeleteItemRecipe: () => widget.deleteItemRecipe.call(itemRecipe),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.recipesFavorites.length,
                    onPageChanged: (int index){
                      setState(() {
                        _activePage = index;
                      });
                    },
                  ),
                ),
                if (widget.recipesFavorites.orEmpty().length > 1 && widget.recipesFavorites.orEmpty().length != _activePage + 1) IconButton(
                  onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List<Widget>.generate(
          //       widget.recipesList.length,
          //           (index) => Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 8),
          //             child: CircleAvatar(
          //               radius: 5,
          //               backgroundColor: _activePage == index
          //                   ? Colors.amber
          //                   : Colors.white30,
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   border: Border.all(
          //                     width: 1,
          //                     color: _activePage == index
          //                         ? Colors.transparent
          //                         : Colors.amber,
          //                   ),
          //                   shape: BoxShape.circle,
          //                 ),
          //               ),
          //             ),
          //     ),
          //   ),
          //   ),
          // )
        ],
      ),
    );
  }

}