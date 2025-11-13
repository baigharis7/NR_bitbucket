import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/bloc/update_sport_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../sportevent/view/sport_event_item.dart';
import '../../widgets/event_options_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';

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
                        const SizedBox(height: Dimens.height12,),
                        if (state.sportSimple?.info?.isNotEmpty == true) const SizedBox(height: Dimens.height12),
                        if (state.sportSimple?.info?.isNotEmpty == true) EventOptionsWidget(
                          name: state.sportSimple?.title,
                          onUpdateName: (name) => updateSportBloc.add(UpdateSportNameUpdateSportEvent(name: name)),
                          scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.sportSimple?.scheduleTime),
                          onUpdateTime: state.sportSimple?.isCreateRoutine == true ? (scheduleTime) => updateSportBloc.add(UpdateSportScheduleTimeUpdateSportEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))) : null,
                          daysOfWeek: state.sportSimple?.daysOfWeek,
                          onUpdateDayOfWeek: state.sportSimple?.isCreateRoutine == true ? (dayOfWeek) => updateSportBloc.add(UpdateSportDayOfWeekUpdateSportEvent(dayOfWeek: dayOfWeek)) : null,
                          ),
                        const SizedBox(height: Dimens.height12,),
                        if (state.sportSimple?.info?.isNotEmpty == true) ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: state.sportSimple?.info?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = state.sportSimple!.info![index];
                            return SportEventItem(
                              allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
                              sport: item,
                              removeSport: () => updateSportBloc.add(RemoveSportItemUpdateSportEvent(sportInfo: item, isGoBack: () => Navigator.pop(context))),
                              editMinutes: (sportInfo) => updateSportBloc.add(UpdateSportItemMinutesUpdateSportEvent(sportInfo: sportInfo)),
                              editIntensity: (sportInfo) => updateSportBloc.add(UpdateSportItemIntensityUpdateSportEvent(sportInfo: sportInfo)),
                            );
                        },),
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
