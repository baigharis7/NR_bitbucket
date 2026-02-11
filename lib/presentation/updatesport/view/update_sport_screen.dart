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
import '../../../infrastructure/utils/constants.dart';

class UpdateSportScreen extends StatelessWidget {
  static const routeName = '/update_sport_screen';
  const UpdateSportScreen({super.key});

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimens.height12),
                        HeaderAddItemCardSection(
                          title: '${AppLocalizations.of(context)!.update} ${AppLocalizations.of(context)!.physical_activity}',
                          onBackTap: () => Navigator.pop(context),
                          image: 'assets/images/sport.png',
                          items: state.sportsInfo?.sportsInfoMaster.map((sport) => sport.translate(context)).toList() ?? [],
                          onItemSelect: (sportName, focus) {
                            // _sportFocusInputController = focus;
                            final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                            final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                            final sportInfo = updateSportBloc.findSportById(sportId);
                            final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                            updateSportBloc.add(UpdateSportItemUpdateSportEvent(sportInfo: info));
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
                          // Item cards with connector lines
                          ...state.sportSimple!.info!.map((item) => Column(
                            children: [
                              Center(
                                child: Container(
                                  width: 1.5,
                                  height: 20,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              SportEventItem(
                                allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
                                sport: item,
                                removeSport: () => updateSportBloc.add(RemoveSportItemUpdateSportEvent(sportInfo: item, isGoBack: () => Navigator.pop(context))),
                                editMinutes: (sportInfo) => updateSportBloc.add(UpdateSportItemMinutesUpdateSportEvent(sportInfo: sportInfo)),
                                editIntensity: (sportInfo) => updateSportBloc.add(UpdateSportItemIntensityUpdateSportEvent(sportInfo: sportInfo)),
                              ),
                            ],
                          )),
                          // Add More button
                          const SizedBox(height: Dimens.height12),
                          Center(
                            child: TextButton.icon(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.yellowishGreen),
                              label: Text(
                                AppLocalizations.of(context)!.add_more,
                                style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w500),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                        const SizedBox(height: Dimens.height32,),
                        if (state.sportSimple?.info?.isNotEmpty == true) GeneralButton(onTap: () {
                          if (state.sportSimple?.title.isNotEmptyOrNull() == true) {
                            updateSportBloc.add(SaveUpdateSportUpdateSportEvent(onFinish: () => Navigator.pop(context)));
                          }
                        },),
                      ],
                    ),
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
