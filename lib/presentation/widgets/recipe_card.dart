import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RecipeCard extends StatefulWidget {
  final RecipeMaster recipeMaster;
  final List<String> ingredientsNames;
  final String image;

  const RecipeCard({
    Key? key,
    required this.recipeMaster,
    required this.ingredientsNames,
    required this.image,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecipeCard();
}

class _RecipeCard extends State<RecipeCard> {

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Card(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          widget.recipeMaster.translate(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(right: Dimens.marginNormal),
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {},
                            child: Image.asset(
                              'assets/icon/share_icon.png',
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginLarge*2, bottom: Dimens.marginNormal),
                  width: mediaQuerySize.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...widget.ingredientsNames.map((name) =>
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
                                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreen[200],
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(3.0),
                                    ),
                                    child: Text(name),
                                  ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border, size: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

}