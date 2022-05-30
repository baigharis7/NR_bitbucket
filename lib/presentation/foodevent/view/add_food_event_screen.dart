import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/json_utils.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/provider/add_food_event_provider.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/autocomplete_list_add_event.dart';
import 'package:provider/provider.dart';

// TODO: tengo que poner lo de las bebidas en algún sitio.
class AddFoodEventScreen extends StatefulWidget {
  static const routeName = '/add_food_event';

  const AddFoodEventScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodEventState();
}

class _AddFoodEventState extends State<AddFoodEventScreen>
    with ShowLoadingDialog, GenericProvider<AddFoodEventProvider> {

  Widget _showConfirmationDialog(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    return Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(Dimens.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color.fromARGB(255, 127, 0, 0), width: 3),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Text(
              'Se ha guardado el evento con éxito',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: Dimens.fontSizeNormal,
                color: Colors.black
              ),
            ),
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<AddFoodEventProvider>(context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (getProvider.getFoodAndDrinksList == null) {
        final Future<Map<String, dynamic>> foodMap = JsonUtils(context: context).readJson('assets/dummy_foods.json');
        getProvider.retrieveFoodAndDrinks(foodMap, nextCall: () {
          if (getProvider.getCookingMethods == null) {
            final Future<Map<String, dynamic>> cookingMethods = JsonUtils(context: context).readJson('assets/cooking_methods.json');
            getProvider.retrieveCookingMethods(cookingMethods, nextCall: () {
              if (getProvider.getCookingMethodsInfo == null) {
                final Future<Map<String, dynamic>> cookingMethodsInfo = JsonUtils(context: context).readJson('assets/cooking_methods_info.json');
                getProvider.retrieveCookingMethodsInfo(cookingMethodsInfo);
              }
            });
          }
        });
      }
    });

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
                    child: const Text(
                      'Add food event',
                      style: TextStyle(
                        fontSize: Dimens.fontSizeLarge,
                      ),
                    )
                  ),
                  getProvider.getFoodAndDrinksList != null
                      ? AutocompleteListAddEvent(provider: getProvider)
                      : Container(),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(Dimens.paddingNormal),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red, Colors.pinkAccent, Colors.green],
                            begin: FractionalOffset.bottomRight,
                            end: FractionalOffset.topRight,
                            stops: [0.1, 0.3, 0.8]
                        ),
                        borderRadius: BorderRadius.all(Radius.elliptical(20.0, 20.0))
                      ),
                      child: const Text(
                        'Add event',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      if (getProvider.getIngredients.isNotEmpty) {
                        getProvider.onFinishClicked(() {
                          Navigator.pop(context);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (getProvider.onSaveFoodEventSuccess) _showConfirmationDialog(context),
          if (getProvider.isLoading) showLoadingDialog(context),
        ]
      ),
    );
  }

}