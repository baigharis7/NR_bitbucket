import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/liquid_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddLiquidEventScreen extends StatefulWidget {
  const AddLiquidEventScreen({Key? key}) : super(key: key);

  static const routeName = '/add_liquid_event';

  @override
  State<StatefulWidget> createState() => _AddLiquidEventScreenState();
}

class _AddLiquidEventScreenState extends State<AddLiquidEventScreen> {
  TextEditingController _foodInputController = TextEditingController();

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
          message:
              AppLocalizations.of(context)!.liquid_event_successfully_saved,
        ),
      ),
    ).then(
      (value) => Navigator.pop(context),
    );
  }

  Future<void> showAddLiquidEventDialog(
    String liquidName,
    LiquidInEvent liquid,
  ) async {
    final bloc = BlocProvider.of<LiquidEventBloc>(context);

    await showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: Dimens.marginNormal),
                    child: Text(liquidName, maxLines: 2),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            AddLiquidEventDialog(
              liquid: liquid,
              currentLanguage: Localizations.localeOf(context).languageCode,
            )
          ],
        );
      },
    ).then((liquidInEvent) {
      if (liquidInEvent != null) {
        bloc.add(AddLiquidFromEventAction(liquid: liquidInEvent));
      }
      setState(() => _foodInputController.text = '');
    });
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<LiquidEventBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  void dispose() {
    _foodInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    final bloc = BlocProvider.of<LiquidEventBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final infoReceived = ModalRoute.of(context)!.settings.arguments;
    if (infoReceived != null) {
      if (infoReceived is LiquidEventSimple?) {
        final liquidEventSimple = infoReceived as LiquidEventSimple?;
        bloc.add(ReceiveLiquidsInEventFromNavigationAction(
            liquidEventSimple: liquidEventSimple!));
      } else if (infoReceived is DateTime?) {
        final eventDate = infoReceived as DateTime?;
        bloc.add(ReceiveEventDateAction(dateTime: eventDate!));
      }
    }

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 24),
            ),
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.liquids,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), child: Image.asset('assets/icon/drink_icon.png', height: 28)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(Dimens.heightSmall),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                  vertical: Dimens.marginLarge,
                ),
                child: Text(
                  AppLocalizations.of(context)!.add_liquid_title,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeXXLarge,
                  ),
                ),
              ),
            ),
          ),
          body: BlocConsumer<LiquidEventBloc, LiquidEventState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
              if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
            },
            builder: (context, state) {
              return WillPopScope(
                onWillPop: () async {
                  bloc.add(ResetLiquidEventInfoAction());
                  return true;
                },
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimens.marginNormal),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: Dimens.marginNormal),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimens.paddingNormal,
                                vertical: Dimens.paddingSmall),
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
                                    fillColor: Colors.black,
                                    labelText: AppLocalizations.of(context)!
                                        .write_here_hint,
                                    suffixIcon: IconButton(
                                      icon: textEditingController.text != ''
                                          ? const Icon(
                                              Icons.highlight_remove,
                                              color: Colors.black,
                                            )
                                          : Container(),
                                      onPressed: () => setState(() =>
                                          textEditingController.text = ''),
                                    ),
                                  ),
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onChanged: (value) => setState(() {
                                    textEditingController;
                                  }),
                                );
                              },
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '' ||
                                    textEditingValue.text.length < 2)
                                  return const Iterable<String>.empty();
                                return state.liquidNames!.foodsAndDrinksNames!
                                    .drinkNames!
                                    .map((item) => item.translate(context))
                                    .where((String option) => option
                                        .toLowerCase()
                                        .contains(textEditingValue.text
                                            .toLowerCase()));
                              },
                              onSelected: (option) {
                                // TODO: manage possible errors
                                final food =
                                    bloc.findLiquidId(option, currentLanguage);
                                showAddLiquidEventDialog(
                                  option,
                                  food!,
                                );
                              },
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            _foodInputController.text == '' &&
                                    state.liquidsInEvent != null &&
                                    state.liquidsInEvent!.isEmpty
                                // TODO: aquí saldrían los FAVORITOS.
                                ? state.weeklyFrequentLiquids.orEmpty().isNotEmpty ? GridView(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Dimens.paddingLarge,),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 0,
                                      crossAxisSpacing: Dimens.marginNormal,
                                      mainAxisExtent: 55.0,
                                      childAspectRatio: 3 / 1,
                                    ),
                                    shrinkWrap: true,
                                    children: [
                                      ...state.weeklyFrequentLiquids.orEmpty()
                                          .map(
                                            (liquid) => Card(
                                              elevation: 3.00,
                                              shadowColor: Colors.black,
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
                                                decoration: BoxDecoration(
                                                  color: state.frequentLiquidAdded?.foodInfo!.map((favorite) => favorite.translate(context)).join(', ') == liquid.foodInfo!.map((favorite) => favorite.translate(context)).join(', ') ? Colors.amber : Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5),),
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10),),
                                                  onTap: () {
                                                    bloc.add(AddLiquidFrequentEventAction(liquidFrequent: liquid));
                                                  },
                                                  child: Text(
                                                    liquid.foodInfo!.map((favorite) => favorite.translate(context)).join(', '),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: Dimens
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ).toList(),
                                    ],
                                  ) : Container()
                                : Column(
                                    children: [
                                      ...state.liquidsInEvent
                                          .orEmpty()
                                          .map(
                                            (liquidInEvent) => LiquidCard(
                                              liquidName: EventsHelper()
                                                  .findFoodNameFromId(
                                                      liquidInEvent.id,
                                                      context,
                                                      state
                                                          .liquidNames!
                                                          .foodsAndDrinksNames!
                                                          .drinkNames!),
                                              quantity:
                                                  liquidInEvent.qty.toString(),
                                              removeLiquid: () => bloc.add(
                                                RemoveLiquidFromEventAction(
                                                  liquid: liquidInEvent,
                                                ),
                                              ),
                                              editLiquid: () {
                                                final option =
                                                    bloc.findLiquidNameFromId(
                                                  liquidInEvent.id,
                                                  context,
                                                );
                                                showAddLiquidEventDialog(
                                                  option,
                                                  liquidInEvent,
                                                );
                                              },
                                            ),
                                          )
                                          .toList()
                                    ],
                                  )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: Dimens.marginXLarge),
                          child: RoundedCustomButton(
                            onPressed: () {
                              if (state.liquidsInEvent!.isEmpty) {
                                if (!state.frequentLiquidAdded.isNull()) {
                                  bloc.add(FinishFrequentLiquidEventAction(onFinish: () => _showConfirmationDialog(context),));
                                }
                              }
                              else {
                                bloc.add(
                                  FinishLiquidEventAction(
                                    onFinish: () =>
                                        _showConfirmationDialog(context),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
