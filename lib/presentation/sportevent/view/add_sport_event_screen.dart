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
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/remove_diac.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../sportitems/view/sport_items_screen.dart';
import '../../widgets/add_item_name_dialog.dart';
import '../../widgets/box_type_radio_text_widget.dart';
import '../../widgets/dash_title_widget.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/food_actions_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/item_info_card.dart';
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

  void _showConfirmationDialog({required BuildContext context, required Function onDismiss}) {
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
      onDismiss.call();
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
        title: '${AppLocalizations.of(context)!.sport_name}:',
        onNameChange: (String sportEventName) =>
            onNameChange.call(sportEventName),
        onSave: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  Future<void> showRoutineTimeDialog({
    required Function(String) onNameChange,
    required Function onTimeChanged,
    required Function(int) onChangeWeekDays,
    required Function(bool) onFavoriteChange,
    required Function(bool) onChangeCreateRoutine,
    required List<int>? daysOfWeek,
    required TimeOfDay? scheduleTime,
    required bool? isFavorite,
    required bool? isCreateRoutine,
    required String? name,
}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ItemRoutineWidget(
        onNameChange: (name) => onNameChange.call(name),
        onTimeChange: (pickedTime) => onTimeChanged.call(pickedTime),
        onChangeWeekDays: (weekDay) => onChangeWeekDays.call(weekDay),
        daysOfWeek: daysOfWeek,
        scheduleTime: scheduleTime,
        isFavorite: isFavorite,
        isCreateRoutine: isCreateRoutine,
        name: name,
        onFavoriteChange: (value) => onFavoriteChange.call(value),
        onChangeCreateRoutine: (value) => onChangeCreateRoutine.call(value),
      ),
    ).then((_) {});
  }

  @override
  void initState() {
    bloc = BlocProvider.of<SportEventsBloc>(context);



    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)!.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is DateTime?) {
            bloc.add(UpdateCalendarDateSportEventAction(calendarDate: infoReceived as DateTime));
          } else if (infoReceived is AddSportFavorite) {
            bloc.add(UpdateSportFromFavoriteTabSportEventsActions(addSportFavorite: infoReceived));
          } else if (infoReceived is SportRoutineCompleted) {
            bloc.add(UpdateSportFromRoutinesTabSportEventsActions(sportRoutineCompleted: infoReceived));
          }
        }
      }
    });
    bloc.add(InitializeStateAction());
    super.initState();
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
                        // padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                        child: Column(
                          children: [
                            const SizedBox(height: Dimens.height12),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall,),
                              child: DatePickerBar(selectedDateTime: state.calendarDate, onChangeDate: (dateTime) {
                                bloc.add(UpdateCalendarDateSportEventAction(calendarDate: dateTime));
                              },),
                            ),
                            const SizedBox(height: Dimens.height12),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              child: HeaderAddItemCardSection(
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
                            ),
                            if (state.sportSimpleEvent?.info?.orEmpty().isNotEmpty == true) Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              child: Column(
                                children: [
                                    ...?state.sportSimpleEvent?.info?.orEmpty().map((sport) => SportEventItem(
                                      allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
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
                                      onNameChange: (name) => bloc.add(SetEventSportNameAction(sportEventName: name)),
                                        onTimeChanged: (time) => bloc.add(UpdateTimeOfDaySportEventAction(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(time))),
                                      onChangeWeekDays: (weekDay) => bloc.add(UpdateDaysOfWeekSportEventAction(weekDay: weekDay)),
                                      onFavoriteChange: (value) => bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: value)),
                                      onChangeCreateRoutine: (value) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: value)),
                                      daysOfWeek: state.sportSimpleEvent?.daysOfWeek,
                                      scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimpleEvent?.scheduleTime),
                                      isFavorite: state.sportSimpleEvent?.isFavorite,
                                      isCreateRoutine: state.sportSimpleEvent?.isCreateRoutine,
                                      name: state.sportSimpleEvent?.title,
                                    ),
                                    title: Text(AppLocalizations.of(context)!.add_more_options),
                                    trailing: const Icon(Icons.add_circle, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            if (state.sportSimpleEvent!.info.orEmpty().isEmpty && state.favSports.orEmpty().isNotEmpty) Column(children: [
                              const SizedBox(height: Dimens.height12),
                              DashTitleWidget(title: AppLocalizations.of(context)!.favorites + ' - ' + AppLocalizations.of(context)!.physical_activity),
                              ...state.favSports.orEmpty().map((favSport) => ItemInfoCard(
                                title: NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: favSport.info, context: context),
                                leadingSrc: 'assets/images/favorite_icon.png',
                                trailingSrc: 'assets/icon/add_icon.png',
                                color: state.sportFavoriteEvent == favSport ? AppColors.butter : AppColors.floralWhite,
                                leadingTap: () => bloc.add(DeleteFavSportSportEventsAction(sportFavorite: favSport, onFinish: () => _showConfirmationDialog(context: context, onDismiss: () {}))),
                                trailingTap: () => bloc.add(AddSportFavoriteFromFavoriteEvent(sportFavorite: favSport)),
                                subtitle: '${favSport.info![0].minutes} ${AppLocalizations.of(context)!.minutes} - ${NutritionUtils.activityIntensityById(favSport.info![0].intensity.orZero(), context)}.',),
                              ),
                            ],),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(Dimens.marginLarge),
                      child: GeneralButton(onTap: () {
                          if (bloc.validateSportList() ?? true) return;

                          if (state.sportSimpleEvent!.info.orEmpty().isEmpty) {
                            if (!state.sportFavoriteEvent.isNull()) {
                              bloc.add(FinishSportFavoriteActions(onFinish: () => _showConfirmationDialog(context: context, onDismiss: () {})));
                            }
                          } else {
                            // FocusScope.of(context).unfocus();
                            // _sportFocusInputController.unfocus();
                            if (state.sportSimpleEvent!.info.orEmpty().length > 1 && (state.sportSimpleEvent?.title.isEmptyOrNull() == true)) {
                              showRoutineTimeDialog(
                                onNameChange: (name) => bloc.add(SetEventSportNameAction(sportEventName: name)),
                                onTimeChanged: (time) => bloc.add(UpdateTimeOfDaySportEventAction(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(time))),
                                onChangeWeekDays: (weekDay) => bloc.add(UpdateDaysOfWeekSportEventAction(weekDay: weekDay)),
                                onFavoriteChange: (value) => bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: value)),
                                onChangeCreateRoutine: (value) => bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: value)),
                                daysOfWeek: state.sportSimpleEvent?.daysOfWeek,
                                scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimpleEvent?.scheduleTime),
                                isFavorite: state.sportSimpleEvent?.isFavorite,
                                isCreateRoutine: state.sportSimpleEvent?.isCreateRoutine,
                                name: state.sportSimpleEvent?.title,
                              );
                            } else if (state.sportSimpleEvent!.info.orEmpty().length == 1 && (state.sportSimpleEvent?.title.isEmptyOrNull() == true)) {
                              final name = NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: [state.sportSimpleEvent?.info.orEmpty()[0]], context: context);
                              bloc.add(SetEventSportNameAction(sportEventName: name));
                            }

                            if (state.sportSimpleEvent!.title.isNotEmptyOrNull()) {
                              bloc.add(FinishSportEventActions(onFinish: () => _showConfirmationDialog(context: context, onDismiss: () {
                                Navigator.popAndPushNamed(context, SportItemsScreen.routeName, arguments: state.calendarDate);
                              })));
                            }
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
