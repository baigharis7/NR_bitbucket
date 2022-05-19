import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../infrastructure/mixins/generic_provider.dart';
import '../../../infrastructure/mixins/show_loading_mixin.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/helpers/i10n_helper.dart';
import '../../../infrastructure/extensions/extensions.dart';
import '../../widgets/autocomplete_list_hits.dart';
import '../../widgets/selectable_option.dart';
import '../provider/registry_provider.dart';

class DietQuestionsModal extends StatefulWidget {
  const DietQuestionsModal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DietQuestionsModalState();
}

class _DietQuestionsModalState extends State<DietQuestionsModal>
    with ShowLoadingDialog, GenericProvider<RegistryProvider> {

  void showAversionsDialog(FoodsAndDrinkListsMaster foodAndDrinks) {
    showDialog(
        useSafeArea: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.instance.translate('choose_aversions')),
            children: [
              AutocompleteListHits(
                data: foodAndDrinks,
              ),
            ],
          );
        },
        context: context);
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
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                    Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                child:
                Text(AppLocalizations.instance.translate('diet_type_question')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                        Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                    child: const Text('Do you eat guts?'),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(Dimens.marginNormal,
                        Dimens.marginXLarge, Dimens.marginLarge, Dimens.zero),
                    child: Checkbox(
                        value: getProvider.getEatGuts,
                        onChanged: (value) => getProvider.setEatGuts(value!),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
                    Dimens.marginNormal, Dimens.marginLarge),
                child: Column(children: <Widget>[
                  ...getProvider.listDietTypes.map((dietType) => SelectableOption(
                    isSelected: getProvider.getDietType == dietType.id,
                    name: dietType.name.toString().orEmpty(),
                    id: dietType.id!,
                    selectedItemsList: [getProvider.getDietType],
                    onTap: (id) => getProvider.manageDietType(id),
                  ),
                  )
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
                    Dimens.marginLarge, Dimens.zero),
                child: Text(
                  AppLocalizations.instance.translate('allergens_question'),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(Dimens.marginNormal, Dimens.zero,
                    Dimens.marginNormal, Dimens.marginLarge),
                child: Column(children: <Widget>[
                  ...getProvider.listAllergens.map(
                        (allergen) => SelectableOption(
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
                  AppLocalizations.instance.translate('intolerances_question'),
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
                        (intolerance) => SelectableOption(
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
                  AppLocalizations.instance.translate('aversions_question'),
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
                            onPressed: () {
                              getProvider.retrieveFoodAndDrinks(
                                  context,
                                  (FoodsAndDrinkListsMaster foodAndDrinks) => showAversionsDialog(foodAndDrinks),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        getProvider.retrieveFoodAndDrinks(context, (foodAndDrinks) => showAversionsDialog(foodAndDrinks));
                      },
                      child: Text(AppLocalizations.instance.translate('choose_aversions'),
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
