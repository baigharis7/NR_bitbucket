import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/provider/add_sport_event_provider.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/autocomplete_sport_event.dart';
import 'package:provider/provider.dart';

class AddSportEventScreen extends StatefulWidget {
  const AddSportEventScreen({Key? key}) : super(key: key);

  static const routeName = '/add_sport_event';
  @override
  State<StatefulWidget> createState() => _AddSportEventScreenState();
}

class _AddSportEventScreenState extends State<AddSportEventScreen> with GenericProvider<AddSportEventProvider>, ShowLoadingDialog {

  // TODO: si esto permanece se puede convertir en un widget en un momento.
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
            border: Border.all(
                color: const Color.fromARGB(255, 127, 0, 0),
                width: 3
            ),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Text(
            'Se ha guardado el evento con éxito',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: Dimens.fontSizeNormal,
                color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setProvider(Provider.of<AddSportEventProvider>(context));

    WidgetsBinding.instance.addPostFrameCallback((_) => getProvider.initialize((ErrorTypes errorType) {
          showErrorSnackBar(context, resolveError(context, errorType));
        },
    ));

    return SafeArea(
        child: Stack(
        children: [
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: Dimens.marginLarge),
                      child: const Text(
                        'Add sport event',
                        style: TextStyle(
                          fontSize: Dimens.fontSizeLarge,
                        ),
                      )),
                  getProvider.getSportsInfo != null
                      ? AutocompleteSportEvent()
                      : Container(),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(Dimens.paddingNormal),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Colors.red,
                                Colors.pinkAccent,
                                Colors.green
                              ],
                              begin: FractionalOffset.bottomRight,
                              end: FractionalOffset.topRight,
                              stops: [0.1, 0.3, 0.8]),
                          borderRadius:
                          BorderRadius.all(Radius.elliptical(20.0, 20.0))),
                      child: const Text(
                        'Add event',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      if (getProvider.getSportId != null) {
                        getProvider.onFinishClicked(
                        () => Navigator.pop(context),
                        (errorTypes) => showErrorSnackBar(context, resolveError(context, errorTypes)));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (getProvider.onSaveSportEventSuccess) _showConfirmationDialog(context),
          if (getProvider.isLoading) showLoadingDialog(context),
        ],
        ),
    );
  }

}