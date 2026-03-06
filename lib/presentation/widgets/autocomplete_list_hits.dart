import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

// TODO: hacer genérico para usarlo en los eventos de comida.
// Pasarle una lista de un objeto que sea sólo id y name.
class AutocompleteListHits extends StatefulWidget {
  final FoodsAndDrinkListsMaster data;
  final Function manageListItems;
  final Function removeSelectedItem;
  final List<FoodItemMaster> aversions;

  const AutocompleteListHits({
    Key? key,
    required this.data,
    required this.manageListItems,
    required this.removeSelectedItem,
    required this.aversions,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutocompleteListHits();
}

class _AutocompleteListHits extends State<AutocompleteListHits> {
  TextEditingController _foodInputController = TextEditingController();

  @override
  void dispose() {
    _foodInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // los nombres de comida en su idioma, y por tanto simplificando la búsqueda.
    final allFoodsAndDrinks = widget.data.getFoodsAndDrinkNamesOrEmpty();
    final onlyNames = allFoodsAndDrinks.map((item) => item.translate(context));

    FoodItemMaster findFoodId(String foodName) {
      final currentLanguage = Localizations.localeOf(context).languageCode;
      return allFoodsAndDrinks.firstWhere((foodOrDrink) {
        if (currentLanguage == 'es') {
          return foodOrDrink.es == foodName;
        } else {
          return foodOrDrink.en == foodName;
        }
      });
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
          Dimens.marginNormal, Dimens.marginLarge,),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                Dimens.zero, Dimens.marginNormal, Dimens.marginLarge,),
            child: Autocomplete<String>(
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
              ) {
                _foodInputController = textEditingController;
                return TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.write_here_hint,
                  ),
                  controller: textEditingController,
                  focusNode: focusNode,
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return onlyNames.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (option) {
                FoodItemMaster foodId = findFoodId(option);
                  // registryProvider.manageAversions(foodId);
                widget.manageListItems.call(foodId.id);
                setState(() {
                  widget.aversions.add(foodId);
                });
                _foodInputController.text = '';
              },
            ),
          ),
          Column(
            children: <Widget>[
              ...widget.aversions.map((aversion) => FittedBox(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: Dimens.marginXLarge),
                        child: Text(
                            aversion.translate(context),
                            maxLines: 2,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            widget.removeSelectedItem(aversion.id);
                            setState(() {
                              widget.aversions.remove(aversion);
                            });
                            },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.amber,
                          ),
                        ),
                      )
                    ],
                ),
              ),
              ).toList(),
            ],
          )
        ],
      ),
    );
  }
}