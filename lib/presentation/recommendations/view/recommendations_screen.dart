import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/json_utils.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/provider/recommendations_provider.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/view/recipe_dialog.dart';
import 'package:provider/provider.dart';

class RecommendationsScreen extends StatefulWidget {
  static const routeName = '/recommendations_screen';

  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with ShowLoadingDialog, GenericProvider<RecommendationsProvider> {

  void _showRecipe(BuildContext context, List<String> ingredientsList) {
    showDialog(context: context, builder: (_) {
      return RecipeDialog(ingredientsList: ingredientsList);
    });
  }

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<RecommendationsProvider>(context));
    String currentLanguage = Localizations.localeOf(context).languageCode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!getProvider.isRecommendationOrdered) {
        final Future<Map<String, dynamic>> recommendationGroups = JsonUtils(context: context).readJson('assets/recommendation_groups.json');
        getProvider.orderRecommendation(recommendationGroups, onSuccess: () {
          final Future<Map<String, dynamic>> foodMap = JsonUtils(context: context).readJson('assets/dummy_foods.json');
          getProvider.retrieveFoodAndDrinks(foodMap);
        });
      }
    });

    return SafeArea(
        child: Stack(
          children: [
            Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (getProvider.getRecommendation != null && getProvider.getFoodAndDrinksList != null)
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginXLarge),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          gradient: LinearGradient(
                            colors: [Color.fromARGB(204, 177, 0, 0), Color.fromARGB(255, 255, 146, 146)],
                            begin: FractionalOffset.bottomRight,
                            end: FractionalOffset.topLeft,
                            stops: [0.1, 0.9],
                          )
                        ),
                        child: Text(
                          AppLocalizations.instance.translate('recommendations'),
                          style: const TextStyle(
                              fontSize: Dimens.fontSizeXLarge,
                              color: Colors.white
                          ),
                        ),
                      ),
                    if (getProvider.getRecommendation != null && getProvider.getFoodAndDrinksList != null)
                      // TODO: cuidado que hay incongruencia con las bebidas, que no las estoy pasando.
                      ...getProvider.getRecommendation!.foodList.map((groupRecommendation) =>
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                getProvider.getRecommendationGroupName(groupRecommendation.recGroup, currentLanguage),
                                style: const TextStyle(
                                  fontSize: Dimens.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                            Container(height: 1, color: Colors.amber,margin: const EdgeInsets.only(left: Dimens.marginNormal),),
                            ...getProvider.getRecommendedFoodNames(groupRecommendation.foods, currentLanguage).map((food) {
                              return GestureDetector(
                                child: Row(
                                  children: [
                                    if (getProvider.isMultiSelectionActive) Checkbox(
                                      activeColor: Colors.teal,
                                      value: getProvider.getSelectedFoodIds.contains(food['id']),
                                      onChanged: (_) {
                                        getProvider.manageSelectedFood(food);
                                        },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(Dimens.paddingSmall),
                                      margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.marginNormal),
                                      alignment: Alignment.centerLeft,
                                      decoration: getProvider.getSelectedFoodIds.contains(food['id'])
                                          ? BoxDecoration(
                                        color: const Color.fromARGB(255, 245, 167, 167),
                                        borderRadius: BorderRadius.circular(20.0)
                                      )
                                          : const BoxDecoration(color: Colors.transparent)
                                      ,
                                      child: Text(
                                          food['foodName'],
                                          style: const TextStyle(
                                            fontSize: Dimens.fontSizeNormal
                                          ),
                                      ),
                                    ),
                                  ]
                                ),
                                onLongPress: () {
                                  if (!getProvider.isMultiSelectionActive) {
                                    getProvider.manageSelectedFood(food);
                                    getProvider.setMultiSelection(true);
                                  }
                                },
                                onTap: () {
                                  if (getProvider.isMultiSelectionActive) getProvider.manageSelectedFood(food);
                                },
                              );
                            }).toList()
                          ],
                        )
                    ).toList(),
                    if (getProvider.getRecommendation == null && getProvider.getFoodAndDrinksList != null) const Text('Loading...')
                  ],
                ),
              ),
              floatingActionButton: getProvider.isMultiSelectionActive
                  ? SizedBox(
                    width: 100,
                    height: 100,
                    child: Container(
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber,
                              blurRadius: 5.0,
                              spreadRadius: 2.0,
                              offset: Offset(3.0, 3.0), // shadow direction: bottom right
                            ),
                          ],
                        shape: BoxShape.circle,
                      ),
                      child: FloatingActionButton(
                        splashColor: Colors.pinkAccent,
                        hoverColor: Colors.amber,
                        elevation: 30,
                        backgroundColor: Colors.teal,
                        onPressed: () {
                          _showRecipe(context, getProvider.getSelectedFoodNames);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: const Text(
                              'Receta!',
                              style: TextStyle(color: Colors.white),
                            ),
                        ),
                      ),
                    ),
                  )
                  : Container(),
            ),
            if (getProvider.isLoading) showLoadingDialog(context)
      ],
    ));
  }
}
