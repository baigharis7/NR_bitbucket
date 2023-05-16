import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/autocomplete_sport_event.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddSportEventScreen extends StatefulWidget {
  const AddSportEventScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = '/add_sport_event';

  @override
  State<StatefulWidget> createState() => _AddSportEventScreenState();
}

class _AddSportEventScreenState extends State<AddSportEventScreen> {

  void _showConfirmationDialog({required BuildContext context, required Function onResetState}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.sport_event_successfully_saved,),
    ),
    ).then((value) {
      onResetState.call();
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<SportEventsBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SportEventsBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final infoReceived = ModalRoute.of(context)!.settings.arguments;
    if (infoReceived != null) {
      if (infoReceived is SportEventSimple?) {
        final sportEventSimple = infoReceived as SportEventSimple?;
          bloc.add(ReceiveSportEventInfoAction(sportEventSimple: sportEventSimple!, context: context));
      } else if (infoReceived is DateTime?) {
        final eventDate = ModalRoute.of(context)!.settings.arguments as DateTime?;
        if (eventDate != null) {
          bloc.add(ReceiveEventDateAction(eventDate: eventDate));
        }
      }
    }

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<SportEventsBloc, SportEventsState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }

              if (state.onError != null) {
                showErrorSnackBar(ctx, resolveError(context, state.onError!));
              }
            },
            builder: (ctx, state) {
              return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                    onPressed: () => Navigator.pop(context),
                  ),
                  backgroundColor: Colors.transparent,
                  titleSpacing: Dimens.marginNormal,
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.journal,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: Dimens.fontSizeLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                body: WillPopScope(
                  onWillPop: () async {
                    bloc.add(ResetSportInfoAction());
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
                          child: Text(
                            AppLocalizations.of(context)!.add_sport_event,
                            style: const TextStyle(
                              fontSize: Dimens.fontSizeLarge,
                            ),
                          ),
                        ),
                        state.sportsInfo != null
                            ? AutocompleteSportEvent(
                              onSetSportName: (sportName, sportId) => bloc.add(SetSportNameAction(
                                sportName: sportName,
                                sportId: sportId,
                                currentLanguage: currentLanguage,
                              ),),
                              onSetMinutes: (minutes) => bloc.add(SetMinutesAction(minutes: minutes,),),
                              onSetIntensity: (intensityIndex) => bloc.add(SetIntensityAction(
                                intensity: intensityIndex,
                                currentLanguage: currentLanguage,
                              ),),
                              onSetTimeStart: (TimeOfDay timeOfDay) => bloc.add(SetTimeStartAction(timeStart: timeOfDay)),
                              onSetDateStart: () => bloc.add(SetDateStartAction()),
                              sportsInfo: state.sportsInfo!,
                              sportName: state.sportName,
                              duration: state.minutes,
                              intensity: state.intensity,
                              timeStart: state.timeStart,
                              dateStart: state.dateStart,
                              sportId: state.sportId,
                              resetSportInfo: () => bloc.add(ResetSportInfoAction()),
                            )
                            : Container(),
                        Container(
                          margin: const EdgeInsets.only(left: Dimens.marginLarge, right: Dimens.marginLarge, ),
                          child: RoundedCustomButton(
                            onPressed: () {
                              if (state.sportName != null) {
                                bloc.add(FinishSportEventAction(onFinish: () => _showConfirmationDialog(
                                  context: ctx, 
                                  onResetState: () => bloc.add(ResetSportInfoAction()),
                                ),),);
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
    );
  }

}