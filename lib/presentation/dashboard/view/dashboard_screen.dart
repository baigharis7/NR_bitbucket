import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/provider/dashboard_provider.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/view/recommendations_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen>
    with ShowLoadingDialog, GenericProvider<DashboardProvider>, SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<DashboardProvider>(context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProvider.initialize((ErrorTypes errorType) => showErrorSnackBar(context, resolveError(context, errorType)));
    });

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(81, 97, 64, 81),
                      Color.fromARGB(75, 227, 135, 0),
                      Color.fromARGB(70, 0, 120, 23)
                    ],
                    stops: [0.1, 0.6, 0.8],
                    begin: FractionalOffset.bottomRight,
                    end: FractionalOffset.topLeft,
                  ),
              ),
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(Dimens.marginSmall),
                    child: Column(
                      children: [
                        FittedBox(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
                            alignment: Alignment.topCenter,
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(5.0))
                            ),
                            child: const Text(
                              'Micronutrients',
                              style: TextStyle(
                                  fontSize: Dimens.fontSizeSmall,
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        // TODO: aquí poner una comprobación buena, no esta tontería.
                        getProvider.getFoodEvents.isEmpty
                            ? const Text('You need to introduce food events')
                            : Column(
                          children: [
                            ...getProvider.getUserMicronutrients.map((micronutrient) =>
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginSmall),
                                        child: Text('${getProvider.getNutrientName(micronutrient, Localizations.localeOf(context).languageCode)}:'),
                                      ),
                                    ),
                                    if (getProvider.getFractionToFill(micronutrient) == 1) Container(
                                        margin: const EdgeInsets.only(
                                            right: Dimens.marginSmall
                                        ), child: const Text(
                                      "!!",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                          margin: const EdgeInsets.only(right: Dimens.marginLarge),
                                          child: LayoutBuilder(
                                              builder: (ctx, constraints) {
                                                return Row(children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.black54, width: 1.0),
                                                      borderRadius: BorderRadius.circular(20.00),
                                                      color: Colors.white12,
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    height: 15,
                                                    width: constraints.maxWidth,
                                                    child: Stack(
                                                        children: [
                                                          Container(
                                                            color: Colors.white30,
                                                            child: FractionallySizedBox(
                                                              alignment: Alignment.centerLeft,
                                                              widthFactor: getProvider.getFractionToFill(micronutrient),
                                                              child: Container(
                                                                alignment: Alignment.centerLeft,
                                                                decoration: BoxDecoration(
                                                                  color: getProvider.getFractionToFill(micronutrient) == 1
                                                                      ? Colors.red
                                                                      : const Color.fromARGB(255, 3, 179, 164),
                                                                  borderRadius: BorderRadius.circular(20.00),
                                                                  shape: BoxShape.rectangle,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]
                                                    ),
                                                  )
                                                ],
                                                );
                                              })
                                      ),
                                    )
                                  ],
                                ),
                            ).toList()
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: Dimens.marginSmall),
                        )
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Card(
                            margin: const EdgeInsets.all(Dimens.marginSmall),
                            child: SizedBox(
                              height: 200,
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: Dimens.marginLarge,),
                                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                      ),
                                      child: const Text(
                                        'Macronutrients',
                                        style: TextStyle(
                                            fontSize: Dimens.fontSizeSmall,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.settings, size: 40.00, color: Colors.grey,),
                                  const Text('We\'re working on it!')
                                ],
                              ),
                            ),
                          ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Card(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          child: Column(
                            children: [
                              FittedBox(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
                                  alignment: Alignment.topCenter,
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(5.0))
                                  ),
                                  child: const Text(
                                    'Liquid intake',
                                    style: TextStyle(
                                        fontSize: Dimens.fontSizeSmall,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(Icons.settings, color: Colors.grey, size: 40.00,),
                              const Text('Under construction!')
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              notchMargin: 6.0,
              color: const Color.fromARGB(255, 151, 21, 21),
              shape: const CircularNotchedRectangle(),
              child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginSmall),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.0)
                        ),
                        child: IconButton(
                          iconSize: 30,
                          icon: const Icon(
                              Icons.home,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final snackBar = SnackBar(
                              content: const Text('Botón de home'),
                              action: SnackBarAction(
                                label: 'Pulsado el botón de home',
                                onPressed: () {
                                  ToastHelper().showToast(
                                      text: 'Esto es un toast',
                                      backgroundColor: const Color.fromARGB(40, 97, 64, 81),
                                      textColor: Colors.white
                                  );
                                },
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginSmall),
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.0)
                        ),
                        child: IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            Icons.food_bank_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AddFoodEventScreen.routeName);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginSmall),
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.0)
                        ),
                        child: IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            Icons.sports_baseball_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AddSportEventScreen.routeName);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginSmall),
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.0)
                        ),
                        child: IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final snackBar = SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.amber),
                                  borderRadius: BorderRadius.circular(5.00),
                              ),
                              backgroundColor: Colors.deepPurpleAccent,
                              content: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.00),
                                    border: Border.all(color: Colors.grey, width: 5.0),
                                    shape: BoxShape.rectangle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(100, 147, 147, 147),
                                        blurRadius: 5.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(-10.0, 20.0), // shadow direction: bottom right
                                      ),
                                    ],
                                    color: Colors.transparent
                                  ),
                                  child: const Text('Botón de perfil'),
                              ),
                              action: SnackBarAction(
                                label: 'Has pulsado el botón de perfil',
                                onPressed: () {
                                  ToastHelper().showToast(
                                      text: 'Esto es un Toast',
                                      backgroundColor: const Color.fromARGB(40, 97, 64, 81),
                                      textColor: Colors.white
                                  );
                                },
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          },
                        ),
                      ),
                    ],
                ),
              ),
            ),
            resizeToAvoidBottomInset: true,
            floatingActionButton: FloatingActionButton(
              elevation: 2.0,
              backgroundColor: const Color.fromARGB(255, 97, 64, 81),
              onPressed: () {
                final snackBar = SnackBar(
                  content: const Text('Botón de algoritmo'),
                  action: SnackBarAction(
                    label: 'Pulsa aquí para ver tu recomendación',
                    onPressed: () {
                      Navigator.pushNamed(context, RecommendationsScreen.routeName);
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Image.asset(
                'assets/images/logo_black.png',
                fit: BoxFit.cover,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
          if (getProvider.isLoading) showLoadingDialog(context),
        ],
      ),
    );
  }

}