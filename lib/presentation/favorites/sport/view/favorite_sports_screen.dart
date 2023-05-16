import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/undo_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/sport_favorites_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/create_new_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_list_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class FavoriteSportsScreen extends StatefulWidget {
  static const routeName = '/favorite_sports';

  const FavoriteSportsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteSportsScreenState();

}

class _FavoriteSportsScreenState extends State<FavoriteSportsScreen> {

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
    ).then((_) => reloadScreen.call());
  }


  @override
  void initState() {
    final bloc = BlocProvider.of<SportFavoritesBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SportFavoritesBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<SportFavoritesBloc, SportFavoritesState>(
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
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sport_favs,
                      style: const TextStyle(color: Colors.black,),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.teal),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        CreateNewSportFavoriteScreen.routeName,
                      ).then((value) => bloc.add(InitializeStateAction())),
                    )
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(Dimens.marginNormal),
                  child: Column(
                    children: [
                      if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                        context: context,
                        explainingCardId: ExplainingCardRefs.addNewSportEvent.index,
                        onHideCard: () => bloc.add(HideExplainingCardAction()),
                        onPressedButton: () => Navigator.pushNamed(context, CreateNewSportFavoriteScreen.routeName),
                      ),
                      ...state.sportFavorites!.map((sportFavorite) => EventListItem(
                        title: sportFavorite.title.orEmpty(),
                        onFavorite: () => showUndoFavoriteDialog(
                          context: ctx,
                          title: sportFavorite.title.orEmpty(),
                          onUndoFavorite: () => bloc.add(
                            RemoveFavoriteAction(
                              sportFavorite: sportFavorite,
                              onFinish: () => Navigator.pop(context),
                            ),
                          ),
                          reloadScreen: () => bloc.add(InitializeStateAction()),
                        ),
                        onEdit: () => Navigator.pushNamed(context, AddSportFavoriteScreen.routeName, arguments: sportFavorite).then((value) => bloc.add(InitializeStateAction())),
                      ),)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}