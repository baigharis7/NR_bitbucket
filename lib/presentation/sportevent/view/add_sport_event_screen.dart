import 'dart:ui';

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
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/remove_diac.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../widgets/add_item_name_dialog.dart';
import '../../widgets/box_type_radio_text_widget.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/food_actions_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/item_routine_widget.dart';

class AddSportEventScreen extends StatefulWidget {
  const AddSportEventScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = '/add_sport_event';

  @override
  State<StatefulWidget> createState() => _AddSportEventScreenState();
}

class _AddSportEventScreenState extends State<AddSportEventScreen> {
  late FocusNode _sportFocusInputController;
  late SportEventsBloc bloc;
  int filteredListLength = 0;

  void _showConfirmationDialog({required BuildContext context}) {
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
    ).then((value) {});
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
        onSave: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  Future<void> showRoutineTimeDialog({
    required Function onTimeChanged,
    required Function(int) onChangeWeekDays,
    required List<int>? daysOfWeek,
    required TimeOfDay? scheduleTime,
}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ItemRoutineWidget(
        onTimeChange: (pickedTime) => onTimeChanged.call(pickedTime),
        onChangeWeekDays: (weekDay) => onChangeWeekDays.call(weekDay),
        daysOfWeek: daysOfWeek,
        scheduleTime: scheduleTime,
      ),
    ).then((_) {});
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
          if (infoReceived is DateTime?) {
            bloc.add(UpdateCalendarDateSportEventAction(calendarDate: infoReceived as DateTime));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventsHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
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
          return Stack(children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'), // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              child: DatePickerBar(selectedDateTime: state.calendarDate, onChangeDate: (dateTime) {
                                bloc.add(UpdateCalendarDateSportEventAction(calendarDate: dateTime));
                              },),
                            ),
                            const SizedBox(height: Dimens.height12),
                            HeaderAddItemCardSection(
                              title: AppLocalizations.of(context)!.add_physical_activity,
                              onBackTap: () => Navigator.pop(context),
                              image: 'assets/images/sport.png',
                              items: state.sportsInfo!.sportsInfoMaster.map((sport) => sport.translate(context)).toList(),
                              onItemSelect: (sportName, focus) {
                                _sportFocusInputController = focus;
                                final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                                final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                                final sportInfo = bloc.findSportById(sportId);
                                final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                                bloc.add(AddSportEventAction(info));
                              },
                            ),
                            if (state.sportSimpleEvent?.info?.orEmpty().isNotEmpty == true) Column(
                              children: [
                                  ...?state.sportSimpleEvent?.info?.orEmpty().map((sport) => SportEventItem(
                                    sportIntensities: eventsHelper.getChosenSportIntensities(sport.translate(context), state.sportsInfo!, currentLanguage),
                                      sport: sport,
                                      removeSport: () => bloc.add(RemoveSportEventAction(sportInfo: sport)),
                                      editMinutes: (updatedSport) => bloc.add(SetMinutesAction(sportInfo: updatedSport)),
                                      editIntensity: (updatedSport) => bloc.add(SetIntensityAction(sportInfo: updatedSport)),
                                    ),
                                  ),
                                ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15),),
                                  tileColor: AppColors.floralWhite,
                                  onTap: () => showRoutineTimeDialog(
                                      onTimeChanged: (time) => bloc.add(UpdateTimeOfDaySportEventAction(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(time))),
                                    onChangeWeekDays: (weekDay) => bloc.add(UpdateDaysOfWeekSportEventAction(weekDay: weekDay)),
                                    daysOfWeek: state.sportSimpleEvent?.daysOfWeek,
                                    scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimpleEvent?.scheduleTime),
                                  ),
                                  title: const Text('Add more options'),
                                  trailing: const Icon(Icons.add_circle, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                      child: SaveButton(onPressed: () {
                          if (bloc.validateSportList() ?? true) return;
                          if (state.sportSimpleEvent?.info.orEmpty().isEmpty == true) return;

                          if (state.sportSimpleEvent!.scheduleTime.isNotEmptyOrNull() && state.sportSimpleEvent!.daysOfWeek.orEmpty().isNotEmpty) {
                            // bloc.add(FinishSportRoutineAddSportAction(onFinish: () => _showConfirmationDialog(context: context)));
                          } else {
                            // FocusScope.of(context).unfocus();
                            // _sportFocusInputController.unfocus();
                            bloc.add(FinishSportEventAction(onFinish: () => _showConfirmationDialog(context: context,)));
                          }
                      },),
                    ),
                  ],
                ),
              ),
            ),
          ],);
        },
      ),
    );
  }
}
