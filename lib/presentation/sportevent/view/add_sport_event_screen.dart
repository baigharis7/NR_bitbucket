import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/sport_event_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/favorites_recent_toggle.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_title_card.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';
import '../../../domain/models/sportevents/sport_arguments_model.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../sportitems/view/sport_items_screen.dart';
import '../../updatesport/view/update_sport_screen.dart';
import '../../widgets/dash_title_widget.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/item_info_card.dart';

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
  final ScrollController _scrollController = ScrollController();
  int filteredListLength = 0;
  bool _showValidation = false;
  bool _showRoutineValidation = false;

  void _showConfirmationDialog({String? message, required BuildContext context, required Function onDismiss}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
          message: message ?? AppLocalizations.of(context)!.sport_event_successfully_saved,
        ),
      ),
    ).then((value) {
      onDismiss.call();
    });
  }

  @override
  void initState() {
    bloc = BlocProvider.of<SportEventsBloc>(context);



    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)!.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is SportArgumentsModel) {
            bloc.add(AddSportArgumentModelEventAction(sportArgumentsModel: infoReceived));
          } else if (infoReceived is DateTime?) {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          final showFavRecent = state.sportSimpleEvent!.info.orEmpty().isEmpty && (state.favSports.orEmpty().isNotEmpty || state.recentSports.orEmpty().isNotEmpty);

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

            GestureDetector(
              onTap: () => _sportFocusInputController.unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                body: SafeArea(
                  child: showFavRecent
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: Dimens.height12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
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
                                    searchHintText: AppLocalizations.of(context)!.search_activity_hint,
                                    items: state.sportsInfo!.sportsInfoMaster.map((sport) => sport.translate(context)).toList(),
                                    onItemSelect: (sportName, focus) {
                                      _sportFocusInputController = focus;
                                      final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                                      final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                                      final sportInfo = bloc.findSportById(sportId);
                                      final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                                      bloc.add(AddSportEventAction(info));
                                      // Auto-scroll to newly added item
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _scrollController.animateTo(
                                          _scrollController.position.maxScrollExtent,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      });
                                      // Auto-title logic
                                      final currentCount = state.sportSimpleEvent!.info.orEmpty().length;
                                      if (currentCount == 0) {
                                        bloc.add(SetEventSportNameAction(sportEventName: sportName));
                                      } else if (currentCount == 1) {
                                        bloc.add(SetEventSportNameAction(sportEventName: ''));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: Dimens.height12),
                                FavoritesRecentToggle(
                                  selectedIndex: state.favRecentTab,
                                  onTap: (index) => bloc.add(SwitchFavRecentTabSportAction(tabIndex: index)),
                                ),
                                const SizedBox(height: Dimens.height5),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 80),
                              children: [
                                if (state.favRecentTab == 0) ...state.recentSports.orEmpty().map((recentSport) => ItemInfoCard(
                                  title: recentSport.title ?? NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: recentSport.info, context: context),
                                  trailingSrc: 'assets/icon/add_icon.png',
                                  color: AppColors.floralWhite,
                                  trailingTap: () {
                                    final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(recentSport);
                                    sportEventSimple.eventId = DateTime.now().millisecondsSinceEpoch;
                                    sportEventSimple.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
                                    bloc.add(FinishSportEventAction(
                                        sportEventSimple: sportEventSimple,
                                        onFinish: () => _showConfirmationDialog(
                                            context: context,
                                            onDismiss: () => Navigator.popAndPushNamed(context, SportItemsScreen.routeName, arguments: state.calendarDate),
                                        ),),);
                                  },
                                  subtitle: recentSport.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.duration}: ${recentSport.info![0].minutes} min. - ${AppLocalizations.of(context)!.intensity}: ${NutritionUtils.activityIntensityById(recentSport.info![0].intensity.orZero(), context)}.',
                                  beforeTrailingSrc: 'assets/icon/edit_icon.png',
                                  beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSportScreen.routeName, arguments: recentSport).then((value) => bloc.add(InitializeStateAction())),
                                ),),
                                if (state.favRecentTab == 1) ...state.favSports.orEmpty().map((favSport) => ItemInfoCard(
                                  title: favSport.title ?? NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: favSport.info, context: context),
                                  leadingSrc: 'assets/images/favorite_icon.png',
                                  trailingSrc: 'assets/icon/add_icon.png',
                                  color: state.sportFavoriteEvent == favSport ? AppColors.butter : AppColors.floralWhite,
                                  leadingTap: () {} /*bloc.add(DeleteFavSportSportEventsAction(sportFavorite: favSport, onFinish: () {}))*/,
                                  trailingTap: () {
                                    final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(favSport);
                                    sportEventSimple.eventId = DateTime.now().millisecondsSinceEpoch;
                                    sportEventSimple.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
                                    bloc.add(FinishSportEventAction(
                                        sportEventSimple: sportEventSimple,
                                        onFinish: () => _showConfirmationDialog(
                                            context: context,
                                            onDismiss: () => Navigator.popAndPushNamed(context, SportItemsScreen.routeName, arguments: state.calendarDate),
                                        ),),);
                                  },
                                  subtitle: favSport.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.duration}: ${favSport.info![0].minutes} min. - ${AppLocalizations.of(context)!.intensity}: ${NutritionUtils.activityIntensityById(favSport.info![0].intensity.orZero(), context)}.',
                                  beforeTrailingSrc: 'assets/icon/edit_icon.png',
                                  beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSportScreen.routeName, arguments: favSport).then((value) => bloc.add(InitializeStateAction())),
                                ),),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
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
                                  searchHintText: AppLocalizations.of(context)!.search_activity_hint,
                                  items: state.sportsInfo!.sportsInfoMaster.map((sport) => sport.translate(context)).toList(),
                                  onItemSelect: (sportName, focus) {
                                    _sportFocusInputController = focus;
                                    final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                                    final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                                    final sportInfo = bloc.findSportById(sportId);
                                    final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                                    bloc.add(AddSportEventAction(info));
                                    // Auto-scroll to newly added item
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _scrollController.animateTo(
                                        _scrollController.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    });
                                    // Auto-title logic
                                    final currentCount = state.sportSimpleEvent!.info.orEmpty().length;
                                    if (currentCount == 0) {
                                      bloc.add(SetEventSportNameAction(sportEventName: sportName));
                                    } else if (currentCount == 1) {
                                      bloc.add(SetEventSportNameAction(sportEventName: ''));
                                    }
                                  },
                                ),
                              ),
                              if (state.sportSimpleEvent?.info?.orEmpty().isNotEmpty == true) Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: Dimens.height12),
                                    // Title card with favorite/routine toggles
                                    ItemTitleCard(
                                      name: state.sportSimpleEvent?.title,
                                      onUpdateName: (name) => bloc.add(SetEventSportNameAction(sportEventName: name)),
                                      isFavorite: state.sportSimpleEvent?.isFavorite ?? false,
                                      onToggleFavorite: () {
                                        if (state.sportSimpleEvent?.isFavorite != true) {
                                          if (state.sportSimpleEvent?.isCreateRoutine == true) bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: false));
                                          bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: true));
                                        } else {
                                          bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: false));
                                        }
                                      },
                                      isRoutine: state.sportSimpleEvent?.isCreateRoutine ?? false,
                                      onToggleRoutine: () {
                                        if (state.sportSimpleEvent?.isCreateRoutine != true) {
                                          if (state.sportSimpleEvent?.isFavorite == true) bloc.add(UpdateIsFavoriteSportEventsActions(isFavorite: false));
                                          bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: true));
                                        } else {
                                          bloc.add(UpdateIsCreateRoutineSportEventsActions(isCreateRoutine: false));
                                        }
                                      },
                                      itemCount: state.sportSimpleEvent!.info.orEmpty().length,
                                      scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimpleEvent?.scheduleTime),
                                      onUpdateTime: (scheduleTime) => bloc.add(UpdateTimeOfDaySportEventAction(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                                      daysOfWeek: state.sportSimpleEvent?.daysOfWeek,
                                      onUpdateDayOfWeek: (dayOfWeek) {},
                                      showRoutineValidation: _showRoutineValidation,
                                    ),
                                    // Item cards with connector lines
                                    ...state.sportSimpleEvent!.info.orEmpty().asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final sport = entry.value;
                                      return Column(
                                        children: [
                                          SportEventItem(
                                            allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
                                            sport: sport,
                                            removeSport: () => bloc.add(RemoveSportEventAction(sportInfo: sport)),
                                            editMinutes: (updatedSport) => bloc.add(SetMinutesAction(sportInfo: updatedSport)),
                                            editIntensity: (updatedSport) => bloc.add(SetIntensityAction(sportInfo: updatedSport)),
                                            showValidation: _showValidation,
                                          ),
                                        ],
                                      );
                                    }),
                                    // Add More button
                                    const SizedBox(height: Dimens.marginSmall),
                                    Center(
                                      child: SizedBox(
                                        width: Dimens.widthLarge,
                                        height: Dimens.height55,
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
                                          tileColor: AppColors.floralWhite,
                                          onTap: () {
                                            if (bloc.validateSportList() ?? false) {
                                              setState(() { _showValidation = true; });
                                              return;
                                            }
                                            setState(() { _showValidation = false; });
                                            _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                            _sportFocusInputController.requestFocus();
                                          },
                                          title: Text(AppLocalizations.of(context)!.add_more),
                                          trailing: const Icon(Icons.add_circle, color: AppColors.yellowishGreen),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Dimens.paddingXLarge),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.sportSimpleEvent?.info?.orEmpty().isNotEmpty == true) Container(
                        margin: const EdgeInsets.all(Dimens.marginLarge),
                        child: GeneralButton(onTap: () {
                            if (bloc.validateSportList() ?? true) {
                              setState(() { _showValidation = true; });
                              _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                              return;
                            }

                            if (state.sportSimpleEvent!.info.orEmpty().isEmpty) {
                              if (!state.sportFavoriteEvent.isNull()) {
                                bloc.add(FinishSportFavoriteActions(onFinish: () => _showConfirmationDialog(context: context, onDismiss: () {})));
                              }
                            } else {
                              // Auto-set title for single items
                              if (state.sportSimpleEvent!.info.orEmpty().length == 1 && (state.sportSimpleEvent?.title.isEmptyOrNull() == true)) {
                                final name = NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: [state.sportSimpleEvent?.info.orEmpty()[0]], context: context);
                                state.sportSimpleEvent?.title = name;
                              }

                              // Block save if combo has no name (inline error is shown in the title card)
                              if (state.sportSimpleEvent!.info.orEmpty().length > 1 && (state.sportSimpleEvent?.title.isEmptyOrNull() == true)) {
                                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                return;
                              }

                              if (state.sportSimpleEvent!.title.isNotEmptyOrNull()) {
                                if (state.sportSimpleEvent?.isFavorite == true) {
                                  state.sportSimpleEvent?.eventId = state.sportSimpleEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
                                  state.sportSimpleEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
                                  bloc.add(FinishSportFavouriteAddSportAction(sportFavorite: state.sportSimpleEvent!, onFinish: () => _showConfirmationDialog(
                                    message: '${AppLocalizations.of(context)!.sport_event_successfully_saved}\n${AppLocalizations.of(context)!.and}\n${AppLocalizations.of(context)!.sport_favorite_successfully_saved}',
                                      context: context,
                                      onDismiss: () => Navigator.popAndPushNamed(context, SportItemsScreen.routeName, arguments: state.calendarDate),
                                  ),),);
                                }
                                else if (state.sportSimpleEvent?.isCreateRoutine == true) {
                                  if (state.sportSimpleEvent!.daysOfWeek.orEmpty().isEmpty) {
                                    setState(() { _showRoutineValidation = true; });
                                    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                    return;
                                  }
                                  state.sportSimpleEvent?.eventId = state.sportSimpleEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
                                  state.sportSimpleEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

                                  final sportRoutineCompleted = mapAddFavSportToSportRoutineCompleted(state.sportSimpleEvent!);
                                  bloc.add(FinishSportRoutineAddSportAction(sportRoutineCompleted: sportRoutineCompleted, onFinish: () => _showConfirmationDialog(
                                    message: AppLocalizations.of(context)!.sport_routine_successfully_saved,
                                      context: context,
                                      onDismiss: () => Navigator.pop(context),
                                  ),),);
                                } else {
                                  state.sportSimpleEvent?.eventId = state.sportSimpleEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
                                  state.sportSimpleEvent?.eventDate = state.calendarDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
                                  final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(state.sportSimpleEvent!);
                                  bloc.add(FinishSportEventAction(sportEventSimple: sportEventSimple, onFinish: () => _showConfirmationDialog(
                                      context: context,
                                      onDismiss: () => Navigator.popAndPushNamed(context, SportItemsScreen.routeName, arguments: state.calendarDate),
                                  ),),);
                                }
                              }
                            }
                        },),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],);
        },
      ),
    );
  }
}
