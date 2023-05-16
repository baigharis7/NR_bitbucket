import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recipe_card.dart';

class RecipeCarousel extends StatefulWidget {
  final String mealTime;
  final List<RecipeMaster> recipesList;
  final List<List<String>> ingredientsNames;
  final List<String> imagesList;

  const RecipeCarousel({
    Key? key,
    required this.mealTime,
    required this.recipesList,
    required this.ingredientsNames,
    required this.imagesList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecipeCarousel();
}

class _RecipeCarousel extends State<RecipeCarousel> {
  final _pageController = PageController(initialPage: 0);
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: Dimens.marginSmall,
              right: Dimens.marginNormal,
              top: Dimens.marginLarge,
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.mealTime.appendColon(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              // margin: const EdgeInsets.all(Dimens.marginNormal),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return RecipeCard(
                        recipeMaster: widget.recipesList[index],
                        ingredientsNames: widget.ingredientsNames[index],
                        image: widget.imagesList[index],
                      );
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.recipesList.length,
                    onPageChanged: (int index){
                      setState(() {
                        _activePage = index;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 500), curve:Curves.easeIn),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn),
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
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