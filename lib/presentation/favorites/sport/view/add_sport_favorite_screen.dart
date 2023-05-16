import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
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
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddCommentDialog(
        onAddComment: (String comment) => onAddComment.call(comment),
        onPop: () => Navigator.pop(ctx),
      ),
    );
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

  @override
  void initState() {
    final bloc = BlocProvider.of<AddFavoriteSportBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddFavoriteSportBloc>(context);
    final sportFavorite = ModalRoute.of(context)!.settings.arguments as SportFavorite;
    bloc.add(SetSportFavoriteAction(sportFavorite: sportFavorite));

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
              body: SingleChildScrollView(
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
                          Text(
                            state.sportFavorite.translate(context),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: Dimens.fontSizeLarge,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: Dimens.marginNormal),
                            child: Image.asset('assets/icon/sport_icon.png'), height: 27, width: 27,)
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey[300]!, width: 1.0),
                      ),
                      padding: const EdgeInsets.all(Dimens.paddingNormal),
                      margin: const EdgeInsets.all(Dimens.marginNormal),
                      child: Column(
                        children: [
                          Card(
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
                                            state.sportFavorite.translate(ctx),
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
                                          child: Text(state.sportFavorite!.minutes.toString()),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            right: Dimens.marginNormal,
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!.minutes.toLowerCase(),
                                          ),
                                        )
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
                                            child: Text(bloc.getIntensityName(ctx, state.sportFavorite!.intensity)),
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                            child: Text('${AppLocalizations.of(context)!.duration}: '),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal),
                                            child: Text('${state.sportFavorite!.timeStart.orEmpty()}   ${DateTimeHelper().formatDayMonthYearDate(state.sportFavorite!.eventDate!)}'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                          ),
                          SizedBox(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.yellow[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(Dimens.marginNormal),
                              child: InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(Dimens.marginNormal),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(AppLocalizations.of(context)!.add_comment),
                                      const Icon(Icons.mode_comment_outlined)
                                    ],
                                  ),
                                ),
                                onTap: () => showAddCommentDialog(
                                  context: context,
                                  onAddComment: (comment) => bloc.add(SetSportFavoriteCommentAction(
                                    comment: comment,
                                    onFinish: () => Navigator.pop(context),
                                  ),),
                                ),
                              ),
                            ),
                          ),
                          if (state.sportFavorite!.comment.isNotEmptyOrNull()) Container(
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
                                        state.sportFavorite!.comment.orEmpty(),
                                        style: const TextStyle(
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.pink[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(Dimens.marginNormal),
                              child: Container(
                                margin: const EdgeInsets.all(Dimens.marginNormal),
                                child: InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(AppLocalizations.of(context)!.make_favorite),
                                      const Icon(Icons.favorite_border)
                                    ],
                                  ),
                                  onTap: () {
                                    showAddFavoriteDialog(
                                      context: ctx,
                                      onNameChange: (String sportName) => bloc.add(SetSportFavoriteNameAction(favoriteName: sportName)),
                                      onFinish: () => bloc.add(FinishAddingFavoriteAction(onFinish: () => _showConfirmationDialog(context))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}