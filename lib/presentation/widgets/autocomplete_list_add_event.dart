import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/provider/add_food_event_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_item.dart';
import 'package:provider/provider.dart';

class AutocompleteListAddEvent extends StatefulWidget {

  const AutocompleteListAddEvent({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutocompleteListAddEvent();
}

class _AutocompleteListAddEvent extends State<AutocompleteListAddEvent> {
  TextEditingController _foodInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddFoodEventProvider>(context);
    String currentLanguage = Localizations.localeOf(context).languageCode;

    final onlyFoodNames = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.map((foodItem) {
      if (currentLanguage == 'es') {
        return foodItem.es.orEmpty();
      } else {
        return foodItem.en.orEmpty();
      }
    }).toList();

    final onlyDrinksNames = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.drinkNames?.map((foodItem) {
      if (currentLanguage == 'es') {
        return foodItem.es.orEmpty();
      } else {
        return foodItem.en.orEmpty();
      }
    }).toList();

    FoodInEvent? findFoodId(String foodName) {
      FoodItemMaster? foodItem;
      if (currentLanguage == 'es') {
        foodItem = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.firstWhere((food) => food.es == foodName);
      } else {
       foodItem = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.firstWhere((food) => food.en == foodName);
      }
      if (foodItem != null) {
        return FoodInEvent(id: foodItem.id!, qty: 0, unit: 0, cookingMethod: -1);
      } else {
        return null;
      }
    }

    String? findFoodGroup(String foodName) {
      FoodItemMaster? foodItem;
      if (currentLanguage == 'es') {
        foodItem = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.firstWhere((food) => food.es == foodName);
      } else {
        foodItem = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.firstWhere((food) => food.en == foodName);
      }
      if (foodItem != null) {
        return foodItem.group;
      } else {
        return null;
      }
    }

    String findFoodName(FoodInEvent foodInEvent) {
      final food = provider.getFoodAndDrinksNames!.foodsAndDrinksNames!.foodNames?.firstWhere((foodItemMaster) => foodItemMaster.id == foodInEvent.id);
      if (currentLanguage == 'es') {
        return food!.es.orEmpty();
      } else {
        return food!.en.orEmpty();
      }
    }

    Future<void> showAddFoodEventDialog(String foodName, FoodInEvent ingredient, String foodGroup) async {
      await showDialog(
        useSafeArea: true,
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: Dimens.marginNormal),
                    child: Text(foodName, maxLines: 2),
                  ),
                  Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel_outlined),
                      ),
                  ),
                ],
              ),
            ),
            children: [
              AddFoodEventItem(
                ingredient: ingredient,
                currentLanguage: currentLanguage,
                foodGroup: foodGroup,
                cookingMethodsInfoMaster: provider.getCookingMethodsInfo!,
                cookingMethodsMaster: provider.getCookingMethods!,
              )
            ],
          );
          },
      ).then((foodInEvent) {
        if (foodInEvent != null) {
          provider.addIngredient(foodInEvent);
        }
        setState(() {
          _foodInputController.text = '';
        });
      });
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero, Dimens.marginNormal, Dimens.marginLarge),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                Dimens.zero, Dimens.marginNormal, Dimens.marginLarge),
            child: Autocomplete<String>(
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted
                  ) {
                      _foodInputController = textEditingController;
                      return TextField(
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.write_here_hint),
                        controller: textEditingController,
                        focusNode: focusNode,
                      );
                      },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return onlyFoodNames!.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (option) {
                // TODO: manage possible errors
                final food = findFoodId(option);
                final foodGroup = findFoodGroup(option);
                showAddFoodEventDialog(option, food!, foodGroup.orEmpty());
              },
            ),
          ),
          Column(
            children: <Widget>[
              if (provider.getIngredients.isNotEmpty)
                ...provider.getIngredients.map((ingredient) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
                              child: Text(findFoodName(ingredient)),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.marginSmall),
                              child: Text('${AppLocalizations.of(context)!.quantity}: ${ingredient.qty}' 'gr'),
                            ),
                          Container(height: 1, color: Colors.amber,),
                        ],
                        ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(100, 177, 217, 212),
                                      border: Border.all(color: Colors.black, width: 1),
                                      shape: BoxShape.circle
                                  ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.red,
                                ),
                              ),
                                onPressed: () {
                                  final foodGroup = findFoodGroup(findFoodName(ingredient));
                                  showAddFoodEventDialog(findFoodName(ingredient), ingredient, foodGroup.orEmpty());
                                },
                              ),
                                IconButton(
                                  onPressed: () => provider.removeIngredient(ingredient),
                                  icon: const Icon(Icons.cancel_outlined),
                              ),
                            ]
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
              if (provider.getIngredients.isEmpty)
                const Center(child: Text('No has elegido comidas todavía'),),
            ],
          ),
        ],
      ),
    );
  }
}