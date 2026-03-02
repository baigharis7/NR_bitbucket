import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/bloc/update_sport_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../sportevent/view/sport_event_item.dart';
import '../../widgets/item_title_card.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';
import '../../../infrastructure/utils/constants.dart';

class UpdateSportScreen extends StatefulWidget {
  static const routeName = '/update_sport_screen';
  const UpdateSportScreen({super.key});

  @override
  State<UpdateSportScreen> createState() => _UpdateSportScreenState();
}

class _UpdateSportScreenState extends State<UpdateSportScreen> {
  final _scrollController = ScrollController();
  FocusNode _focusInputController = FocusNode();
  bool _showValidation = false;
  final List<GlobalKey> _itemKeys = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventsHelper = EventsHelper();

    final updateSportBloc = BlocProvider.of<UpdateSportBloc>(context);
    updateSportBloc.add(InitializationUpdateSportEvent());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)!.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is AddSportFavorite) {
            updateSportBloc.add(GetSportFromArgumentUpdateSportEvent(sport: infoReceived));
          }
        }
      }
    });

    return BlocProvider.value(
      value: updateSportBloc,
      child: BlocConsumer<UpdateSportBloc, UpdateSportState>(
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

            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                    child: Column(
                      children: [
                        ScreenTopBar(
                          selectedDate: null,
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: Dimens.height12),
                        HeaderAddItemCardSection(
                          title: '${AppLocalizations.of(context)!.update} ${AppLocalizations.of(context)!.physical_activity}',
                          image: 'assets/images/sport.png',
                          searchHintText: AppLocalizations.of(context)!.search_activity_hint,
                          items: state.sportsInfo?.sportsInfoMaster.map((sport) => sport.translate(context)).toList() ?? [],
                          onFocusNodeCreated: (node) => _focusInputController = node,
                          onItemSelect: (sportName, focus) {
                            _focusInputController = focus;
                            final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                            final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                            final sportInfo = updateSportBloc.findSportById(sportId);
                            final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                            updateSportBloc.add(UpdateSportItemUpdateSportEvent(sportInfo: info));
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                        ),
                        if (state.sportSimple?.info?.isNotEmpty == true) ...[
                          const SizedBox(height: Dimens.height12),
                          // Title card with favorite/routine toggles
                          ItemTitleCard(
                            name: state.sportSimple?.title,
                            onUpdateName: (name) => updateSportBloc.add(UpdateSportNameUpdateSportEvent(name: name)),
                            isFavorite: state.sportSimple?.isFavorite ?? false,
                            onToggleFavorite: () {
                              if (state.sportSimple?.isFavorite != true) {
                                if (state.sportSimple?.isCreateRoutine == true) updateSportBloc.add(UpdateIsRoutineUpdateSportEvent(isRoutine: false));
                                updateSportBloc.add(UpdateIsFavoriteUpdateSportEvent(isFavorite: true));
                              } else {
                                updateSportBloc.add(UpdateIsFavoriteUpdateSportEvent(isFavorite: false));
                              }
                            },
                            isRoutine: state.sportSimple?.isCreateRoutine ?? false,
                            onToggleRoutine: () {
                              if (state.sportSimple?.isCreateRoutine != true) {
                                if (state.sportSimple?.isFavorite == true) updateSportBloc.add(UpdateIsFavoriteUpdateSportEvent(isFavorite: false));
                                updateSportBloc.add(UpdateIsRoutineUpdateSportEvent(isRoutine: true));
                              } else {
                                updateSportBloc.add(UpdateIsRoutineUpdateSportEvent(isRoutine: false));
                              }
                            },
                            itemCount: state.sportSimple?.info?.length ?? 0,
                            scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimple?.scheduleTime),
                            onUpdateTime: (scheduleTime) => updateSportBloc.add(UpdateSportScheduleTimeUpdateSportEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                            daysOfWeek: state.sportSimple?.daysOfWeek,
                            onUpdateDayOfWeek: (dayOfWeek) => updateSportBloc.add(UpdateSportDayOfWeekUpdateSportEvent(dayOfWeek: dayOfWeek)),
                          ),
                          ...state.sportSimple!.info!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            while (_itemKeys.length <= index) { _itemKeys.add(GlobalKey()); }
                            return SportEventItem(
                                key: _itemKeys[index],
                                allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
                                sport: item,
                                removeSport: () => updateSportBloc.add(RemoveSportItemUpdateSportEvent(sportInfo: item, isGoBack: () => Navigator.pop(context))),
                                editMinutes: (sportInfo) => updateSportBloc.add(UpdateSportItemMinutesUpdateSportEvent(sportInfo: sportInfo)),
                                editIntensity: (sportInfo) => updateSportBloc.add(UpdateSportItemIntensityUpdateSportEvent(sportInfo: sportInfo)),
                                showValidation: _showValidation,
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
                                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                  _focusInputController.requestFocus();
                                },
                                title: Text(AppLocalizations.of(context)!.add_more),
                                trailing: const Icon(Icons.add_circle, color: AppColors.yellowishGreen),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                      ),
                      if (state.sportSimple?.info?.isNotEmpty == true) Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.marginSmall),
                        child: GeneralButton(onTap: () {
                          final hasErrors = state.sportSimple?.info?.any((sport) => sport.minutes == null || sport.minutes! <= 0 || sport.intensity == null) ?? false;
                          if (hasErrors) {
                            setState(() { _showValidation = true; });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final items = state.sportSimple?.info ?? [];
                              for (int i = 0; i < items.length; i++) {
                                final sport = items[i];
                                if (sport.minutes == null || sport.minutes! <= 0 || sport.intensity == null) {
                                  if (i < _itemKeys.length && _itemKeys[i].currentContext != null) {
                                    Scrollable.ensureVisible(_itemKeys[i].currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                  }
                                  break;
                                }
                              }
                            });
                            return;
                          }
                          setState(() { _showValidation = false; });
                          if (state.sportSimple?.title.isNotEmptyOrNull() == true) {
                            updateSportBloc.add(SaveUpdateSportUpdateSportEvent(onFinish: () => Navigator.pop(context)));
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
