import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_state.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_item_with_edit_and_like.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_info_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class JournalSportScreen extends StatefulWidget {
  const JournalSportScreen({Key? key}) : super(key: key);

  static const routeName = '/journal_sport';

  @override
  State<StatefulWidget> createState() => _JournalSportScreenState();

}

class _JournalSportScreenState extends State<JournalSportScreen> {

  @override
  void initState() {
    final bloc = BlocProvider.of<JournalSportBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<JournalSportBloc>(context);
    final mediaQuerySize = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<JournalSportBloc, JournalSportState>(
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
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, top: Dimens.marginNormal),
                  width: mediaQuerySize.width,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 25)),
                              Text(
                                AppLocalizations.of(context)!.sport,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: Dimens.fontSizeLarge,
                                ),
                              ),
                              Container(
                                height: 28,
                                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                child: Image.asset('assets/icon/sport_icon.png'),),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, AddSportEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                                icon: const Icon(Icons.add_circle, color: Colors.teal, size: 30),
                              )
                            ],
                          )
                        ],
                      ),
                      if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                        context: context,
                        explainingCardId: ExplainingCardRefs.addNewSportEvent.index,
                        onHideCard: () => bloc.add(HideExplainingCardAction()),
                        onPressedButton: () => Navigator.pushNamed(context, AddSportEventScreen.routeName),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
                        child: Text(AppLocalizations.of(context)!.today, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      state.todaySportEvents!.isNotEmpty
                          ? GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          childAspectRatio: 3/2,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...state.todaySportEvents!.map((sportEvent) {
                            return EventItemWithEditAndLike(
                              name: bloc.getSportName(sportEvent.info.id, ctx),
                              isFavorite: bloc.isSportFavorite(sportEvent),
                              onEdit: () {
                                Navigator.pushNamed(
                                  context,
                                  AddSportFavoriteScreen.routeName,
                                  arguments: mapToSportFavorite(sportEvent),
                                ).then((value) {
                                  bloc.add(InitializeStateAction());
                                });
                              },
                              onFavorite: () {
                                //Pasted here function from above function for future use if need
                                // Navigator.pushNamed(
                                //   context,
                                //   AddSportEventScreen.routeName,
                                //   arguments: mapToSportEventSimple(sportEvent),
                                // ).then((value) {
                                //   bloc.add(InitializeStateAction());
                                // });
                              },
                            );
                          }).toList()
                        ],
                      )
                          : Container(
                              margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                              child: Text(AppLocalizations.of(context)!.no_sport_events),
                            ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, top: Dimens.marginLarge),
                        child: Text(AppLocalizations.of(context)!.this_week),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                        child: WeeklyInfoCard(
                          weeklyData: state.weeklyData ?? [],
                          kcals: state.userKcal ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: const CustomBottomAppBar(initStateCallback: null,),
              resizeToAvoidBottomInset: true,
              floatingActionButton: FloatingActionButton(
                elevation: 2.0,
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(Dimens.paddingSmall),
                  child: Image.asset(
                    'assets/images/logo_black.png',
                    fit: BoxFit.cover,
                    color: Colors.black,
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            );
          },
        ),
      ),
    );
  }

}