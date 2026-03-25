import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/liquid_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_state.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/view/add_water_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_item_with_edit_and_like.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/horizontal_water_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_info_card.dart';

import '../../common/view/confirmation_dialog.dart';

class JournalLiquidScreen extends StatefulWidget {
  static const routeName = '/journal_liquid';

  const JournalLiquidScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalLiquidScreen();
}

class _JournalLiquidScreen extends State<JournalLiquidScreen> {
  late JournalLiquidBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<JournalLiquidBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      message: AppLocalizations.of(context)!.delete_liquid,
    ),).then(
      (value) => bloc.add(InitializeStateAction()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<JournalLiquidBloc>(context);
    final eventsHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<JournalLiquidBloc, JournalLiquidState>(
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
          builder: (ctx, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(ctx);
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
                    // Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), child: Image.asset('assets/icon/drink_icon.png', height: 28)),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(Dimens.heightSmall),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                    child: Text(AppLocalizations.of(context)!.today, style: const TextStyle(fontWeight: FontWeight.bold,),),
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: Column(
                          children: [
                            if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                              context: context,
                              explainingCardId: ExplainingCardRefs.addNewLiquidEvent.index,
                              onHideCard: () => bloc.add(HideExplainingCardAction()),
                              onPressedButton: () => Navigator.pushNamed(context, AddLiquidEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                            ),
                            // HorizontalWaterBar(
                            //   waterTaken: eventsHelper.getWaterIntakeAddition(state.waterEvents, state.todayLiquidEvents.orEmpty()),
                            //   fractionToFill: eventsHelper.getWaterFractionToFillFromEvents(state.waterEvents, state.todayLiquidEvents.orEmpty(), ((state.userProfile?.physicalCharacteristics?.weight ?? 0) * 0.035)),
                            //   onAddWater: () => Navigator.pushNamed(context, AddWaterEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                            //   cardElevation: 2,
                            // ),
                            state.todayLiquidEvents!.isNotEmpty
                                ? Column(
                              children: [
                                ...state.todayLiquidEvents!.map((liquidEvent) {
                                  return EventItemWithEditAndLike(
                                    name: liquidEvent.foodInfo!.map((food) => food.translate(context)).join(', '),
                                    isFavorite: /** TODO: aquí poner la lógica de los favoritos */ false,
                                    onEdit: () {
                                      Navigator.pushNamed(
                                        context,
                                        AddLiquidEventScreen.routeName,
                                        arguments: mapToLiquidEventSimple(liquidEvent),
                                      ).then((value) {
                                        bloc.add(InitializeStateAction());
                                      });
                                    },
                                    onDetail: () => Navigator.pushNamed(
                                        context,
                                        AddLiquidEventScreen.routeName,
                                        arguments: mapToLiquidEventSimple(liquidEvent),
                                    ).then((value) {
                                      bloc.add(InitializeStateAction());
                                    }),
                                    onFavorite: () => Navigator.pushNamed(
                                      context,
                                      AddFoodFavoriteScreen.routeName,
                                      arguments: mapToFoodFavoriteList(liquidEvent.foodInfo!),
                                    ),
                                    onDelete: () => bloc.add(DeleteLiquidEventAction(liquidEventComplete: liquidEvent, onFinish: () => _showConfirmationDialog(context))),
                                  );
                                }),
                              ],
                            )
                                : Container(
                                    margin: const EdgeInsets.only(bottom: Dimens.marginLarge, top: Dimens.marginLarge),
                                    child: Text(AppLocalizations.of(context)!.no_liquid_events),
                                  ),
                            // Container(
                            //   alignment: Alignment.centerLeft,
                            //   margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                            //   child: Text(
                            //     AppLocalizations.of(context)!.this_week,
                            //     style: const TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            // WeeklyInfoCard(
                            //   weeklyData: state.weeklyData ?? [],
                            //   kcals: state.userKcal!,
                            //   cardElevation: 2,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge, bottom: Dimens.marginSmall),
                    child: GeneralButton(
                      title: AppLocalizations.of(context)!.add,
                      onTap: () => Navigator.pushNamed(ctx, AddLiquidEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.JOURNAL)
              // const CustomBottomAppBar(initStateCallback: null,),
              // resizeToAvoidBottomInset: true,
              // floatingActionButton: FloatingActionButton(
              //   elevation: 2.0,
              //   backgroundColor: Colors.white,
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.all(Dimens.paddingSmall),
              //     child: Image.asset(
              //       'assets/images/logo_black.png',
              //       fit: BoxFit.cover,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            );
          },
        ),
      ),
    );
  }
  
}