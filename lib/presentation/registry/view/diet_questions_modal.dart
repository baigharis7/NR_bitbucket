import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/registry/provider/registry_provider.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/autocomplete_list_hits.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/multi_selectable_option.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/selectable_option.dart';
import 'package:provider/provider.dart';

class DietQuestionsModal extends StatefulWidget {
  const DietQuestionsModal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DietQuestionsModalState();
}

class _DietQuestionsModalState extends State<DietQuestionsModal>
    with ShowLoadingDialog, GenericProvider<RegistryProvider> {

  void showAversionsDialog(FoodsAndDrinkListsMaster? foodAndDrinks) {
    showDialog(
        useSafeArea: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context)!.choose_aversions),
            children: [
              AutocompleteListHits(
                data: foodAndDrinks!,
              ),
            ],
          );
        },
        context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<RegistryProvider>(context, listen: true));

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(
                    Dimens.marginNormal,
                    Dimens.marginXLarge,
                    Dimens.marginLarge,
                    Dimens.zero
                ),
                child:
                Text(AppLocalizations.of(context)!.diet_type_question),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(
                    Dimens.marginNormal,
                    Dimens.zero,
                    Dimens.marginNormal,
                    Dimens.zero),
                child: Column(children: <Widget>[
                  ...getProvider.listDietTypes.map((dietType) => SelectableOption(
                    name: dietType.name.toString().orEmpty(),
                    id: dietType.id!,
                    selectedOption: getProvider.getDietType ?? 0,
                    onTap: (id) => getProvider.manageDietType(id),
                  ),
                  )
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(
                        Dimens.marginNormal,
                        Dimens.zero,
                        Dimens.marginLarge,
                        Dimens.marginLarge
                    ),
                    child: const Text('Do you eat guts?'),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                        Dimens.zero, Dimens.marginLarge, Dimens.marginLarge),
                    child: Checkbox(
                        value: getProvider.getEatGuts,
                        onChanged: (value) => getProvider.setEatGuts(value!),
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
                    Dimens.marginLarge, Dimens.zero),
                child: Text(
                  AppLocalizations.of(context)!.allergens_question,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
                    Dimens.marginNormal, Dimens.marginLarge),
                child: Column(children: <Widget>[
                  ...getProvider.listAllergens.map(
                        (allergen) => MultiSelectableOption(
                      isSelected: getProvider.getAllergens.contains(allergen.id),
                      name: allergen.name.toString().orEmpty(),
                      id: allergen.id!,
                      selectedItemsList: getProvider.getAllergens,
                      onTap: (id) => getProvider.manageAllergen(id),
                    ),
                  )
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                    Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                child: Text(
                  AppLocalizations.of(context)!.intolerances_question,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(
                  Dimens.marginNormal,
                  Dimens.zero,
                  Dimens.marginNormal,
                  Dimens.marginLarge,
                ),
                child: Column(children: <Widget>[
                  ...getProvider.listIntolerances.map(
                        (intolerance) => MultiSelectableOption(
                      isSelected: getProvider.getIntolerances.contains(intolerance.id),
                      name: intolerance.name.toString().orEmpty(),
                      id: intolerance.id!,
                      selectedItemsList: getProvider.getIntolerances,
                      onTap: (id) => getProvider.manageIntolerance(id),
                    ),
                  )
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                    Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                child: Text(
                  AppLocalizations.of(context)!.aversions_question,
                ),
              ),
              getProvider.getAversions.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(Dimens.marginXLarge,
                              Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...getProvider.getAversions.map((aversion) => Text(aversion.en.orEmpty())).toList()
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                              Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showAversionsDialog(getProvider.getFoodsAndDrinksNamesMaster!.foodsAndDrinksNames),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => showAversionsDialog(getProvider.getFoodsAndDrinksNamesMaster!.foodsAndDrinksNames),
                      child: Text(AppLocalizations.of(context)!.choose_aversions,
                      ),
                    ),
              Container(margin: const EdgeInsets.only(bottom: Dimens.marginLarge),)
            ],
          ),
        ),
        if (getProvider.isLoading) showLoadingDialog(context),
      ]
    );
  }
}
