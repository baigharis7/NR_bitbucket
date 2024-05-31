import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/sport_event_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../domain/models/routines/sport_routine_completed.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../widgets/add_item_name_dialog.dart';
import '../../widgets/box_type_radio_text_widget.dart';

class AddSportEventScreen extends StatefulWidget {
  const AddSportEventScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = '/add_sport_event';

  @override
  State<StatefulWidget> createState() => _AddSportEventScreenState();
}

class _AddSportEventScreenState extends State<AddSportEventScreen> {
  TextEditingController _sportInputController = TextEditingController();
  late FocusNode _sporFocustInputController;
  late SportEventsBloc bloc;

  void _showConfirmationDialog(
      {required BuildContext context, required Function onResetState}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
          message: AppLocalizations.of(context)!.sport_event_successfully_saved,
        ),
      ),
    ).then((value) {
      onResetState.call();
      Navigator.pop(context);
    });
  }

  Future<void> showAddSportNameDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddItemNameDialog(
        title: '${AppLocalizations.of(context)!.spor_name}:',
        onNameChange: (String sportEventName) =>
            onNameChange.call(sportEventName),
        onFinish: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  void initState() {
    bloc = BlocProvider.of<SportEventsBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)!.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is SportEventSimple?) {
            bloc.add(ReceiveSportEventInfoAction(sportEventSimple: infoReceived as SportEventSimple, context: context));
          } else if (infoReceived is DateTime?) {
              bloc.add(ReceiveEventDateAction(eventDate: infoReceived as DateTime));
          } else if (infoReceived is SportEventComplete) {
            bloc.add(AddSportEventFromDetailNavigation(sportEventComplete: infoReceived));
          } else if (infoReceived is SportRoutineCompleted) {
            bloc.add(AddSportRoutineFromRoutineEventAction(sportRoutineCompleted: infoReceived));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final bloc = BlocProvider.of<SportEventsBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventsHelper = EventsHelper();
    // final infoReceived = ModalRoute.of(context)!.settings.arguments;
    // if (infoReceived != null) {
    //   if (infoReceived is SportEventSimple?) {
    //     final sportEventSimple = infoReceived as SportEventSimple?;
    //     bloc.add(ReceiveSportEventInfoAction(
    //         sportEventSimple: sportEventSimple!, context: context));
    //   } else if (infoReceived is DateTime?) {
    //     final eventDate =
    //         ModalRoute.of(context)!.settings.arguments as DateTime?;
    //     if (eventDate != null) {
    //       bloc.add(ReceiveEventDateAction(eventDate: eventDate));
    //     }
    //   } else if (infoReceived is SportEventComplete) {
    //     final sportEventComplete =
    //         ModalRoute.of(context)!.settings.arguments as SportEventComplete;
    //     bloc.add(AddSportEventFromDetailNavigation(
    //         sportEventComplete: sportEventComplete));
    //   }
    // }

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
                      AppLocalizations.of(context)!.add_sport_event,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeXXLarge,
                      ),
                    ),
                  ),
                ),
              ),
              body: WillPopScope(
                onWillPop: () async {
                  bloc.add(ResetSportInfoAction());
                  return true;
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: Dimens.paddingLarge,
                      horizontal: Dimens.paddingXLarge),
                  child: Column(
                    children: [
                      Autocomplete<String>(
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          _sportInputController = textEditingController;
                          _sporFocustInputController = focusNode;
                          return TextField(
                            decoration: InputDecoration(
                              fillColor: Colors.black,
                              labelText: AppLocalizations.of(context)!.enter,
                              suffixIcon: IconButton(
                                icon: textEditingController.text != ''
                                    ? const Icon(
                                        Icons.highlight_remove,
                                        color: Colors.black,
                                      )
                                    : Container(),
                                onPressed: () {
                                  setState(() {
                                    textEditingController.text = '';
                                  });
                                },
                              ),
                            ),
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (value) {
                              setState(() {
                                textEditingController;
                              });
                            },
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return state.sportsInfo!.sportsInfoMaster
                              .map((sport) => sport.translate(context))
                              .where((String name) => name
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (sportName) {
                          final sportIntensities =
                              eventsHelper.getChosenSportIntensities(sportName,
                                  state.sportsInfo!, currentLanguage);
                          final sportId = eventsHelper.getSportIdByName(
                              sportName, state.sportsInfo!, currentLanguage);
                          final sportInfo = bloc.findSportById(sportId);
                          final info = SportInfo(
                              id: sportId,
                              name_en: sportInfo.en,
                              name_es: sportInfo.es,
                              intensity: sportIntensities == 1 ? 0 : null,
                              timeStart: DateTime.now().millisecondsSinceEpoch);
                          bloc.add(AddSportEventAction(info));
                          _sportInputController.text = '';
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimens.paddingLarge,
                          ),
                          child: Column(
                            children: [
                              _sportInputController.text == '' &&
                                      state.info.orEmpty().isEmpty
                                  ? GridView(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: Dimens.marginNormal,
                                        mainAxisExtent: 55.0,
                                        childAspectRatio: 3 / 1,
                                      ),
                                      shrinkWrap: true,
                                      children: [
                                        ...state.sportsFavorite.orEmpty().map(
                                              (sport) => Card(
                                                elevation: 3.00,
                                                shadowColor: Colors.black,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        state.eventSportName ==
                                                                sport.title
                                                            ? Colors.amber
                                                            : Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(5)),
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    onTap: () {
                                                      bloc.add(
                                                          AddSportFromFavoriteAction(
                                                              sportInfo:
                                                                  sport));
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        sport.title.toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: Dimens
                                                              .fontSizeSmall,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        if (state.info?.isNotEmpty ?? false)
                                          ...state.info.orEmpty().map(
                                                (sport) => SportEventItem(
                                                  sportIntensities: eventsHelper
                                                      .getChosenSportIntensities(
                                                          sport.translate(
                                                              context),
                                                          state.sportsInfo!,
                                                          currentLanguage),
                                                  sport: sport,
                                                  removeSport: () {
                                                    bloc.add(
                                                        RemoveSportEventAction(
                                                            sportInfo: sport));
                                                  },
                                                  editMinutes: (updatedSport) =>
                                                      bloc.add(SetMinutesAction(
                                                          sportInfo:
                                                              updatedSport)),
                                                  editIntensity:
                                                      (updatedSport) => bloc.add(
                                                          SetIntensityAction(
                                                              sportInfo:
                                                                  updatedSport)),
                                                  editDateTime: (updatedSport) =>
                                                      bloc.add(
                                                          SetTimeStartAction(
                                                              sportInfo:
                                                                  updatedSport)),
                                                ),
                                              ),
                                        IconButton(
                                          onPressed: () { _sporFocustInputController.requestFocus(); },
                                          icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                                        ),
                                        BoxTypeRadioTextWidget(
                                            onPressed: () =>
                                                bloc.add(UpdateCreateRoutine()),
                                            isSelected:
                                                state.isCreateRoutine ?? false,
                                            showHourDays: true,
                                            routineHour: DateTimeHelper.formatTimeOfDay(state.routineHour, context),
                                            changeHour: (timeOfDay) => bloc.add(UpdateRoutineHourEventAction(timeOfDay: timeOfDay)),
                                            changeDate: (dateTime) => bloc.add(UpdateRoutineDateEventAction(dateTime: dateTime)),
                                            routineDay: DateTimeHelper.formatDateTimeToDay(state.routineDate, currentLanguage: currentLanguage),
                                            title: AppLocalizations.of(context)!
                                                .create_routine),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                      RoundedCustomButton(
                        onPressed: () {
                          if (state.sportFromFavorite?.isEmpty ?? true) {
                            if (bloc.validateSportList() ?? true) return;
                            if (state.info.orEmpty().isEmpty) return;

                              if (state.isCreateRoutine ?? false) {
                                if(state.routineHour.isNull() || state.routineDate.isNull()) return;
                                if (state.info.orEmpty().length > 1) {
                                  showAddSportNameDialog(
                                    context: context,
                                    onFinish: () => bloc.add(FinishCreateRoutineEventAction(onFinish: () => _showConfirmationDialog(context: ctx, onResetState: () => bloc.add(ResetSportInfoAction()),),),),
                                    onNameChange: (sportEventName) => bloc.add(SetEventSportNameAction(sportEventName: sportEventName)),
                                  );
                                } else {
                                  state.eventSportName = state.info.orEmpty().map((e) => bloc.findSportById(e.id!).translate(context)).toString();
                                  bloc.add(FinishCreateRoutineEventAction(onFinish: () => _showConfirmationDialog(context: ctx, onResetState: () => bloc.add(ResetSportInfoAction()),),),);
                                }
                              } else {
                                // state.eventSportName = state.info.orEmpty().map((e) => bloc.findSportById(e.id!).translate(context)).toString();
                                // if(state.info.orEmpty().length > 1) {
                                //   showAddSportNameDialog(
                                //     context: context,
                                //     onFinish: () => bloc.add(FinishWithoutRoutineEventAction(onFinish: () => _showConfirmationDialog(context: ctx, onResetState: () => bloc.add(ResetSportInfoAction()),), context: context),),
                                //     onNameChange: (sportEventName) => bloc.add(SetEventSportNameAction(sportEventName: sportEventName)),
                                //   );
                                // } else {
                                  bloc.add(FinishWithoutRoutineEventAction(onFinish: () => _showConfirmationDialog(context: ctx, onResetState: () => bloc.add(ResetSportInfoAction()),),context: context),);
                                // }
                              }
                          } else {
                            bloc.add(FinishSportFavoriteAction(onFinish: () => _showConfirmationDialog(context: ctx, onResetState: () => bloc.add(ResetSportInfoAction()))));
                          }
                        },
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
