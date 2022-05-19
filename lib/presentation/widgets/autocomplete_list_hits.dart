import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:provider/provider.dart';

// TODO: hacer genérico para usarlo en los eventos de comida.
// Pasarle una lista de un objeto que sea sólo id y name.
class AutocompleteListHits extends StatefulWidget {
  final FoodsAndDrinkListsMaster data;

  const AutocompleteListHits({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutocompleteListHits();
}

class _AutocompleteListHits extends State<AutocompleteListHits> {
  TextEditingController  _foodInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final registryProvider = Provider.of<RegistryProvider>(context);

    // TODO: Mover de aquí. Cuando baje los JSON de AWS eso se hará en el repositorio, dándole a Presentación sólo
    // los nombres de comida en su idioma, y por tanto simplificando la búsqueda.
    final allFoodsAndDrinks = [...widget.data.drinkNames!.toList(), ...widget.data.foodNames!.toList()];
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final onlyNames = allFoodsAndDrinks.map((foodItem) {
      if (currentLanguage == 'es') {
        return foodItem.es.orEmpty();
      } else {
        return foodItem.en.orEmpty();
      }
    }).toList();

    FoodItemMaster findFoodId(String foodName) {
      if (currentLanguage == 'es') {
        return allFoodsAndDrinks
            .firstWhere((foodOrDrink) => foodOrDrink.es == foodName);
      } else {
        return allFoodsAndDrinks
            .firstWhere((foodOrDrink) => foodOrDrink.en == foodName);
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
          Dimens.marginNormal, Dimens.marginLarge),
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
                  VoidCallback onFieldSubmitted,
              ) {
                _foodInputController = textEditingController;
                return TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.instance.translate('write_here_hint'),),
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
                setState(() {
                  registryProvider.manageAversions(foodId);
                  _foodInputController.text = '';
                });
              },
            ),
          ),
          Column(
            children: <Widget>[
              ...registryProvider.getAversions
                  .map(
                    (aversion) => FittedBox(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(
                              left: Dimens.marginXLarge),
                          child: Text(currentLanguage == 'en'
                              ? aversion.en.orEmpty()
                              : aversion.es.orEmpty(),
                                  maxLines: 2),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                registryProvider.removeAversion(aversion);
                              });
                            },
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.amber),
                          ),
                        )
                      ]),
                    ),
              )
                  .toList(),
            ],
          )
        ],
      ),
    );
  }
}