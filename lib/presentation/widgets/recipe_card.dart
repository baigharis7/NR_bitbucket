import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.marginNormal),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.recipeMaster.translate(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Image.asset(
                    'assets/icon/share_icon.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                width: mediaQuerySize.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // ...widget.ingredientsNames
                        ...['Avena','Nueces','Pasa','Avena','Nueces','Pasa',].map((name) =>
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
                              decoration: BoxDecoration(
                                color: AppColors.cardGreen_200,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                              child: Text(name),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}