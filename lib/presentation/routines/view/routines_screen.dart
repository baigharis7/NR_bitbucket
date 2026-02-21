import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/calender_event_list_item.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/mappers/favorites_mapper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../favorites/common/undo_favorite_dialog.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/general_button.dart';
import '../../../infrastructure/utils/constants.dart';

class RoutinesScreen extends StatefulWidget {
  static const routeName = 'routines_screen';

  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  late RoutinesBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutinesBloc>(context);
    bloc.add(RoutinesInitialStateAction());
    super.initState();
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
    ).then((_) => bloc.add(RoutinesInitialStateAction()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<RoutinesBloc, RoutinesState>(
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
        builder: (context, state) => Scaffold(
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.journal,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimens.marginNormal),
                    child: Image.asset('assets/icon/journal_icon.png',
                        height: 28)),
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
                  AppLocalizations.of(context)!.routines,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeXXLarge,
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(child: Column(children: [
            ...state.routines.orEmpty().map((sportRoutine) => CalenderEventListItem(
                title: sportRoutine.sportName.toString(),
                onEdit: () { Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: sportRoutine).then((value) => Navigator.pop(context)); },
                onDelete: () => bloc.add(RoutineDeleteEventAction(sportRoutineCompleted: sportRoutine, onFinish: () => Navigator.pop(context))),
              isFavourite: bloc.isFoundObjectFromFavoriteList(mapToSportFavoriteFromRoutine(sportRoutine)) == null ? false : true,
              onHeartClick: () {
                  if (bloc.isFoundObjectFromFavoriteList(mapToSportFavoriteFromRoutine(sportRoutine)) == null) {
                    bloc.add(RoutineFavoriteEventAction(sportRoutineCompleted: sportRoutine, onFinish: () => Navigator.pop(context)));
                  } else {
                    showUndoFavoriteDialog(
                      context: context,
                      title: sportRoutine.sportName.orEmpty(),
                      reloadScreen: () => bloc.add(RoutinesInitialStateAction()),
                      onUndoFavorite: () {
                        bloc.add(RemoveRoutineFavoriteEventAction(sportRoutineCompleted: sportRoutine, onFinish: () => Navigator.pop(context)));
                      },
                    );
                  }
              },
            ),
            ),
            Container(
              margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge),
              child: GeneralButton(
                title: '${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.routines}',
                onTap: () => Navigator.pushNamed(context, AddSportEventScreen.routeName).then((value) => Navigator.pop(context)),
              ),
            ),
          ],),),
        ),
      ),),
    );
  }
}
