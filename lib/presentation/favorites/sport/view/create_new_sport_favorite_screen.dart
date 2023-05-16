import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/create_new_sport_favorite_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/autocomplete_sport_event.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class CreateNewSportFavoriteScreen extends StatefulWidget {
  static const routeName = '/create_new_sport_favorite';

  const CreateNewSportFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewSportFavoriteScreenState();

}

class _CreateNewSportFavoriteScreenState extends State<CreateNewSportFavoriteScreen> {

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

  Future<void> showAddFavoriteDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
    required Function onResetInfo,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddFavoriteDialog(
        onNameChange: (String sportName) => onNameChange.call(sportName),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) {
      onResetInfo.call();
      Navigator.pop(context);
    });
  }


  @override
  void initState() {
    final bloc = BlocProvider.of<CreateNewSportFavoriteBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CreateNewSportFavoriteBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<CreateNewSportFavoriteBloc, CreateNewSportFavoriteState>(
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                titleSpacing: Dimens.marginNormal,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                          child: Text(
                            AppLocalizations.of(context)!.add_favorite,
                            style: const TextStyle(
                              fontSize: Dimens.fontSizeXXLarge,
                            ),
                          ),
                        ),
                        state.sportsInfo != null
                            ? AutocompleteSportEvent(
                          onSetSportName: (String sportName, int sportId) => bloc.add(SetSportIdAction(
                            sportId: sportId,
                          ),),
                          onSetMinutes: (minutes) => bloc.add(SetMinutesAction(minutes: int.parse(minutes),),),
                          onSetIntensity: (intensityIndex) => bloc.add(SetIntensityAction(
                            intensity: intensityIndex,
                            currentLanguage: currentLanguage,
                          ),),
                          onSetTimeStart: (TimeOfDay timeOfDay) => bloc.add(SetTimeStartAction(timeOfDay: timeOfDay)),
                          sportsInfo: state.sportsInfo!,
                          sportName: state.sportId == null ? '' : EventsHelper().getSportNameById(state.sportId, state.sportsInfo!.sportsInfoMaster).translate(context),
                          resetSportInfo: () => bloc.add(ResetFavoriteSportInfoAction()),
                          favoriteName: state.favoriteSportName.orEmpty(),
                        )
                            : Container(),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: RoundedCustomButton(
                        buttonText: AppLocalizations.of(context)!.save_favorite,
                        onPressed: () {
                          if (state.sportId != null) {
                            showAddFavoriteDialog(
                              context: ctx,
                              onNameChange: (String sportName) => bloc.add(SetSportFavoriteNameAction(favoriteName: sportName)),
                              onFinish: () => bloc.add(FinishCreateSportFavoriteAction(currentLanguage: currentLanguage, onFinish: () => _showConfirmationDialog(context))),
                              onResetInfo: () => bloc.add(ResetFavoriteSportInfoAction()),
                            );
                          } else {
                            ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                          }
                        },
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