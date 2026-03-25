import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_comment_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/create_new_sport_favorite_screen.dart';

import '../../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../sportevent/view/add_sport_event_screen.dart';
import '../../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../common/undo_favorite_dialog.dart';
import '../../food/view/create_new_food_favorite_screen.dart';

class AddSportFavoriteScreen extends StatefulWidget {
  static const routeName = '/add_sport_favorite';

  const AddSportFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSportFavoriteScreenState();

}

class _AddSportFavoriteScreenState extends State<AddSportFavoriteScreen> {

  Future<void> showAddCommentDialog({
    required BuildContext context,
    required Function onAddComment,
    required Function onSaveComment,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddCommentDialog(
        onEdit: (String comment) => onAddComment.call(comment),
        onSaveClick: () => onSaveComment.call(),
      ),
    ).then((value) => Navigator.pop(context));
  }

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
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      message: AppLocalizations.of(context)!.sport_event_successfully_saved,
      iconData: Icons.star_rounded,
      hint: AppLocalizations.of(context)!.confirmation_edit_hint_favorites,
    ),).then((value) => Navigator.pop(context));
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
    final bloc = BlocProvider.of<AddFavoriteSportBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddFavoriteSportBloc>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      if (arguments is SportEventComplete) {
        bloc.add(SetSportEventAction(sportEventComplete: arguments));
      }
      else if (arguments is AddSportFavorite) {
        bloc.add(SetSportFromFavoriteAction(sportFavorite: arguments));
      }
    }

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<AddFavoriteSportBloc, AddFavoriteSportState>(
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
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios, size: 25,),
                                  ),
                                ),
                                Expanded(flex: 20,
                                  child: Text(
                                    state.sportInfo.orEmpty().map((favorite) => favorite.translate(ctx)).join(', '),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: Dimens.fontSizeLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                  child: Image.asset('assets/icon/sport_icon.png'), height: 27, width: 27,),
                                const Spacer(),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: InkWell(onTap: () {
                                    if (arguments is AddSportFavorite) {
                                      showUndoFavoriteDialog(
                                              context: ctx,
                                              title: (arguments).title.orEmpty(),
                                          reloadScreen: () => bloc.add(InitializeStateAction()),
                                              onUndoFavorite: (){
                                                bloc.add(
                                                  RemoveFavoriteAction(
                                                    sportFavorite: arguments,
                                                    onFinish: () => Navigator.pop(context),
                                                  ),
                                                );
                                                },
                                      );
                                    } else if (arguments is SportEventComplete) {
                                      if (bloc.isSportFavo(arguments)) {
                                        showUndoFavoriteDialog(
                                          context: ctx,
                                          title: (arguments).sportName.orEmpty(),
                                          reloadScreen: () => bloc.add(InitializeStateAction()),
                                          onUndoFavorite: () {
                                            bloc.add(
                                              RemoveFavoriteAction(
                                                sportFavorite: bloc.isFoundObjectFromFavoriteList(mapToSportFavoriteFromEventComplete(arguments)),
                                                onFinish: () => Navigator.pop(context),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        bloc.add(FinishAddingFavoriteAction(onFinish: () => _showConfirmationDialog(context)));
                                      }
                                    }
                                  }
                                  // (arguments is AddSportFavorite || (arguments is SportEventComplete ? bloc.isSportFavo(arguments) : true)) ? () {
                                  //   showUndoFavoriteDialog(
                                  //     context: ctx,
                                  //     title: (arguments as AddSportFavorite).title.orEmpty(),
                                  //     onUndoFavorite: (){
                                  //       bloc.add(
                                  //         RemoveFavoriteAction(
                                  //           sportFavorite: arguments,
                                  //           onFinish: () => Navigator.pop(context),
                                  //         ),
                                  //       );
                                  //     },
                                  //     //     () => bloc.add(
                                  //     //   RemoveFavoriteAction(
                                  //     //     sportFavorite: arguments,
                                  //     //     onFinish: () => Navigator.pop(context),
                                  //     //   ),
                                  //     // ),
                                  //     reloadScreen: () => bloc.add(InitializeStateAction()),
                                  //   );
                                  // } : () {
                                  //   showAddFavoriteDialog(
                                  //     context: ctx,
                                  //     onNameChange: (String sportName) => bloc.add(SetSportFavoriteNameAction(favoriteName: sportName)),
                                  //     onFinish: () => bloc.add(FinishAddingFavoriteAction(onFinish: () => _showConfirmationDialog(context))),
                                  //   );
                                  // }
                                  , child: (arguments is AddSportFavorite || (arguments is SportEventComplete ? bloc.isSportFavo(arguments) : true)) ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border, color: Colors.red,),),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(Dimens.paddingNormal),
                            margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    if (state.sportInfo?.isNotEmpty  ?? false) ...state.sportInfo!.map((sport) => Card(
                                      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
                                      color: Colors.green[100],
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: Dimens.marginNormal,
                                          right: Dimens.marginNormal,
                                          top: Dimens.marginLarge,
                                          bottom: Dimens.marginLarge,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: Dimens.marginNormal,
                                                    bottom: Dimens.marginNormal,
                                                  ),
                                                  child: Text(
                                                    sport.translate(context),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal,),
                                                  child:
                                                  Text(AppLocalizations.of(context)!.duration),
                                                ),
                                                Expanded(
                                                  child: Text(sport.minutes.toString()),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: Dimens.marginNormal,
                                                  ),
                                                  child: Text(
                                                    AppLocalizations.of(context)!.minutes.toLowerCase(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                                  child: Text(AppLocalizations.of(context)!.intensity),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                                    child: Text(bloc.getIntensityName(ctx, sport.intensity)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                                    child: Text('${AppLocalizations.of(context)!.sport_time_start}: '),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                                    child: Text(DateFormat('hh:mm a, MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(sport.timeStart.toString())))),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),),
                                    if (state.comment.isNotEmptyOrNull()) Container(
                                      margin: const EdgeInsets.all(Dimens.marginNormal),
                                      child: Card(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.all(Dimens.marginNormal),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                                child: Text(
                                                  state.comment.orEmpty(),
                                                  style: const TextStyle(
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingLarge),
                    decoration: const BoxDecoration(borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(5.0)),color: Colors.white,boxShadow: [BoxShadow(blurRadius: 5.0)]),
                    child: Column(children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.all(Dimens.marginXSmall),
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.add_new_sport_button_text),
                                const Icon(Icons.add_circle),
                              ],
                            ),
                            onTap: () {
                              if (arguments is SportEventComplete) {
                                Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: arguments).then((value) => Navigator.pop(context));
                              } else if (arguments is AddSportFavorite) {
                                Navigator.pushNamed(context, CreateNewSportFavoriteScreen.routeName, arguments: arguments).then((value) => Navigator.pop(context));
                              }
                              },
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.all(Dimens.marginXSmall),
                        child: InkWell(
                          child: Container(
                            margin: const EdgeInsets.all(Dimens.marginSmall),
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.add_comment),
                                const Icon(Icons.mode_comment_outlined),
                              ],
                            ),
                          ),
                          onTap: () => showAddCommentDialog(
                            context: context,
                            onAddComment: (comment) => bloc.add(UpdateSportCommentEventAction(comment: comment),),
                            onSaveComment: () { arguments is SportEventComplete ? bloc.add(FinishSportCommentEventAction(onFinish: () => _showConfirmationDialog(context))) :  bloc.add(FinishFavoriteSportCommentAction(onFinish: () => _showConfirmationDialog(context))); },
                          ),
                        ),
                      ),
                    ],),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}