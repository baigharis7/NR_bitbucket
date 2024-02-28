import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_state.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_item_with_edit_and_like.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_info_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_favorite_dialog.dart';

import '../../../infrastructure/mappers/favorites_mapper.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../favorites/common/undo_favorite_dialog.dart';

class JournalSportScreen extends StatefulWidget {
  const JournalSportScreen({Key? key}) : super(key: key);

  static const routeName = '/journal_sport';

  @override
  State<StatefulWidget> createState() => _JournalSportScreenState();

}

class _JournalSportScreenState extends State<JournalSportScreen> {
  Future<void> showAddFavoriteDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddFavoriteDialog(
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.sport_event_successfully_saved,),
    ),
    ).then((value) => Navigator.pop(context));
  }

  Future<void> showUndoFavoriteDialog({
    required BuildContext context,
    required String title,
    required Function onUndoFavorite,
    required reloadScreen,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return UndoFavoriteDialog(
          title: title,
          onUndoFavorite: () => onUndoFavorite.call(),
        );
      },
    ).then((_) => Navigator.pop(context));
  }

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
                      AppLocalizations.of(context)!.sport,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: Dimens.fontSizeXXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), child: Image.asset('assets/icon/sport_icon.png', height: 28)),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(Dimens.heightSmall),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                    child: Row(
                      children: [
                        Expanded(child: Text(AppLocalizations.of(context)!.today, style: const TextStyle(fontWeight: FontWeight.bold,),)),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, AddSportEventScreen.routeName).then((value) => bloc.add(InitializeStateAction())),
                          icon: const Icon(Icons.add_circle, color: Colors.teal,),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, top: Dimens.marginNormal),
                  width: mediaQuerySize.width,
                  child: Column(
                    children: [
                      if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                        context: context,
                        explainingCardId: ExplainingCardRefs.addNewSportEvent.index,
                        onHideCard: () => bloc.add(HideExplainingCardAction()),
                        onPressedButton: () => Navigator.pushNamed(context, AddSportEventScreen.routeName),
                      ),
                      state.todaySportEvents!.isNotEmpty
                          ? Column(
                        children: [
                          ...state.todaySportEvents!.map((sportEvent) {
                            return EventItemWithEditAndLike(
                              name: sportEvent.sportName.toString(),
                              isFavorite: bloc.isSportFavorite(sportEvent),
                              onEdit: () {
                                Navigator.pushNamed(
                                  context,
                                  AddSportFavoriteScreen.routeName,
                                  arguments: sportEvent,
                                ).then((value) {
                                  bloc.add(InitializeStateAction());
                                });
                              },
                              onFavorite: () {
                                if(!bloc.isSportFavorite(sportEvent)) {
                                  bloc.add(FinishAddSportToFavoriteAction(onFinish: () => _showConfirmationDialog(context), sportEvent: sportEvent));
                                } else {
                                  showUndoFavoriteDialog(
                                    context: ctx,
                                    title: sportEvent.sportName.orEmpty(),
                                    reloadScreen: () => bloc.add(InitializeStateAction()),
                                    onUndoFavorite: () {
                                      bloc.add(
                                        RemoveFavoriteSportAction(
                                          sportFavorite: bloc.isFoundObjectFromFavoriteList(mapToSportFavoriteFromEventComplete(sportEvent)),
                                          onFinish: () => Navigator.pop(context),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              onDelete: () => bloc.add(DeleteSportEventAction(sportEventComplete: sportEvent, onFinish: () => _showConfirmationDialog(context))),
                            );
                          }).toList()
                        ],
                      )
                          : Container(
                              margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                              child: Text(AppLocalizations.of(context)!.no_sport_events),
                            ),
                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, top: Dimens.marginLarge),
                      //   child: Text(AppLocalizations.of(context)!.this_week),
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                      //   child: WeeklyInfoCard(
                      //     weeklyData: state.weeklyData ?? [],
                      //     kcals: state.userKcal ?? 0,
                      //   ),
                      // ),
                    ],
                  ),
                ),
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