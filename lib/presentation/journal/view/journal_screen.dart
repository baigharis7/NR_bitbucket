import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/view/calendar_screen.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/create_new_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/favorite_foods_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/create_new_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/favorite_sports_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_urine_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/food/view/food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_state.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_food_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_liquid_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_sport_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/routines/view/routines_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/modifiable_center_box_with_watch_and_add.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_icon_box_with_graphic_watch_and_add.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_graphic.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  static const routeName = '/journal';

  @override
  State<StatefulWidget> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {

  @override
  void initState() {
    final bloc = BlocProvider.of<JournalBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<JournalBloc>(context)..add(InitializeStateAction());
    final mediaQuerySize = MediaQuery.of(context).size;
    final _explainingCardsHelper = ExplainingCardsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<JournalBloc, JournalState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
            },
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.grey[200],
                body: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.only(left: Dimens.marginLarge, top: Dimens.marginLarge, right: Dimens.marginNormal),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: Dimens.marginXSmall, bottom: Dimens.marginNormal),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.journal,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: Dimens.fontSizeXLarge,
                                    ),
                                  ),
                                  Container(
                                    height: 28,
                                    margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                    child: Image.asset('assets/icon/journal_icon.png'),
                                  )
                                ],
                              ),
                            ),
                            // TextIconBox(
                            //   title: AppLocalizations.of(context)!.calendar,
                            //   color: Colors.grey,
                            //   onAdd: () => bloc.add(CalendarClickAction(action: () => Navigator.pushNamed(context, CalendarScreen.routeName))),
                            //   icon: Icons.calendar_today_outlined,
                            //   showAddButton: true,
                            // ),
                            Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ModifiableCenterBoxWithWatchAndAdd(
                                        title: AppLocalizations.of(context)!.food,
                                        onAddPressed: () => bloc.add(FoodsClickAction(action: () => Navigator.of(context).pushNamed(AddFoodEventScreen.routeName))),
                                        onWatchPressed: () => bloc.add(FoodsClickAction(action: () => Navigator.of(context).pushNamed(JournalFoodScreen.routeName))),
                                        centerWidget: SizedBox(
                                          height: 70,
                                          width: 70,
                                          child: Image.asset('assets/icon/fork_knife.png', color: Colors.teal, height: 51, width: 41,),
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: ModifiableCenterBoxWithWatchAndAdd(
                                    //     title: AppLocalizations.of(context)!.liquids,
                                    //     onAddPressed: () => bloc.add(LiquidsClickAction(action: () => Navigator.of(context).pushNamed(AddLiquidEventScreen.routeName))),
                                    //     onWatchPressed: () => bloc.add(LiquidsClickAction(action: () => Navigator.of(context).pushNamed(JournalLiquidScreen.routeName))),
                                    //     centerWidget: SizedBox(
                                    //       height: 90,
                                    //       width: 15,
                                    //       child: FillVerticalBar(
                                    //         fractionToFill: EventsHelper().getWaterFractionToFillFromEvents(state.waterEvents, state.todayLiquidEvents.orEmpty(), state.todayFoodEvents.orEmpty(), ((state.userProfile?.physicalCharacteristics?.weight ?? 0) * 0.035)),
                                    //         barColor: Colors.blue,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                                if (state.calendarCard != null && state.calendarCard!.showCard!) SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: _explainingCardsHelper.getExplainingCardWithId(
                                    context: context,
                                    explainingCardId: ExplainingCardRefs.journalCalendar.index,
                                    onHideCard: () => bloc.add(HideCalendarCardAction()),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                // Card(
                                //   child: TextIconBoxWithGraphicWatchAndAdd(
                                //     title: AppLocalizations.of(context)!.sport,
                                //     calories: bloc.getTodaysKcal(state.todaySportEvents!),
                                //     onAdd: () => bloc.add(SportsClickAction(action: () => Navigator.pushNamed(context, AddSportEventScreen.routeName))),
                                //     onWatch: () => bloc.add(SportsClickAction(action: () => Navigator.pushNamed(context, JournalSportScreen.routeName))),
                                //     graphic: WeeklyGraphic(data: state.weeklyData!,),
                                //   ),
                                // ),
                                if (state.foodsCard != null && state.foodsCard!.showCard!) Center(
                                  child: _explainingCardsHelper.getExplainingCardWithId(
                                    context: context,
                                    explainingCardId: ExplainingCardRefs.journalFoods.index,
                                    onHideCard: () => bloc.add(HideFoodsCardAction()),
                                    onPressedButton: () => Navigator.of(context).pushNamed(AddFoodEventScreen.routeName),
                                  ),
                                ),
                                if (state.liquidsCard != null && state.liquidsCard!.showCard!) Center(
                                  child: _explainingCardsHelper.getExplainingCardWithId(
                                    context: context,
                                    explainingCardId: ExplainingCardRefs.journalLiquids.index,
                                    onHideCard: () => bloc.add(HideLiquidsCardAction()),
                                    onPressedButton: () => Navigator.of(context).pushNamed(AddLiquidEventScreen.routeName),
                                  ),
                                ),
                              ],
                            ),
                            TextIconBox(
                              title: AppLocalizations.of(context)!.food_favs,
                              isCentered: false,
                              showWatchButton: true,
                              onAdd: () => Navigator.pushNamed(context, CreateNewFoodFavoriteScreen.routeName,),
                              onWatch: () => Navigator.pushNamed(context, FavoriteFoodsScreen.routeName),
                              showAddButton: true,
                            ),
                            TextIconBox(
                              title: AppLocalizations.of(context)!.sport,
                              onAdd: () => bloc.add(SportsClickAction(action: () => Navigator.pushNamed(context, AddSportEventScreen.routeName))),
                              onWatch: () => bloc.add(SportsClickAction(action: () => Navigator.pushNamed(context, JournalSportScreen.routeName))),
                              showWatchButton: true,
                              showAddButton: true,
                              isCentered: true,
                            ),
                            TextIconBox(
                              title: AppLocalizations.of(context)!.sport_favs,
                              isCentered: false,
                              showWatchButton: true,
                              onAdd: () => Navigator.pushNamed(context, CreateNewSportFavoriteScreen.routeName),
                              onWatch: () => Navigator.pushNamed(context, FavoriteSportsScreen.routeName),
                              showAddButton: true,
                            ),
                            // TextIconBox(
                            //   title: AppLocalizations.of(context)!.faeces_urine,
                            //   color: Colors.grey,
                            //   onAdd: () => Navigator.pushNamed(context, FecesUrineTabHolder.routeName),
                            //   image: 'assets/images/intestine.png',
                            //   showAddButton: true,
                            // ),
                            TextIconBox(
                              title: AppLocalizations.of(context)!.routines,
                              color: Colors.grey,
                              onAdd: () => Navigator.pushNamed(context, RoutinesScreen.routeName),
                              icon: Icons.remove_red_eye_outlined,
                              showAddButton: true,
                            ),
                          ],
                        ),
                        if (state.showGeneralCard != null && state.showGeneralCard!) Positioned(
                          top: 100,
                          width: mediaQuerySize.width-25,
                          child: Container(
                            child: _explainingCardsHelper.getExplainingCardWithId(
                              context: context,
                              explainingCardId: ExplainingCardRefs.journalGeneral.index,
                              onHideCard: () => bloc.add(HideGeneralCardAction()),
                          ),
                        ),
                        ),
                        if (state.sportsCard != null && state.sportsCard!.showCard!) Positioned(
                          width: mediaQuerySize.width-25,
                          child: _explainingCardsHelper.getExplainingCardWithId(
                            context: context,
                            explainingCardId: ExplainingCardRefs.journalSports.index,
                            onHideCard: () => bloc.add(HideSportsCardAction()),
                            onPressedButton: () => Navigator.of(context).pushNamed(AddSportEventScreen.routeName),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.JOURNAL,)
                // const CustomBottomAppBar(initStateCallback: null,),
                // resizeToAvoidBottomInset: true,
                // floatingActionButton: FloatingActionButton(
                //   elevation: 2.0,
                //   backgroundColor: Colors.white,
                //   onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
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