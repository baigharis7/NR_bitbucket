import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/sportupdate/bloc/sport_update_bloc.dart';

import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../sportevent/view/sport_event_item.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';

class SportUpdateScreen extends StatefulWidget {
  static const routeName = '/sport_update_screen';

  const SportUpdateScreen({super.key});

  @override
  State<SportUpdateScreen> createState() => _SportUpdateScreenState();
}

class _SportUpdateScreenState extends State<SportUpdateScreen> {
  FocusNode _focusInputController = FocusNode();
  late SportUpdateBloc sportUpdateBloc;
  final _scrollController = ScrollController();
  bool _showValidation = false;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    sportUpdateBloc = BlocProvider.of<SportUpdateBloc>(context);
    sportUpdateBloc.add(InitializeSportUpdateEvent());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((timeStamp) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        if (arguments is SportEventComplete) {
          sportUpdateBloc.add(AddSportFromNavSportUpdateEvent(sportEvent: arguments));
        }
      }
    });
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
      value: sportUpdateBloc,
      child: BlocConsumer<SportUpdateBloc, SportUpdateState>(
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
        builder: (context, state) => Stack(
          children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingSmall,
                        vertical: Dimens.paddingLarge),
                    child: Column(children: [
                      ScreenTopBar(
                        selectedDate: DateTimeHelper.dateTimeFromMilliseconds(state.sportSimpleEvent?.eventDate),
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: Dimens.height12),
                      HeaderAddItemCardSection(
                        title: AppLocalizations.of(context)!.edit + ' ' + AppLocalizations.of(context)!.physical_activity,
                        image: 'assets/images/sport.png',
                        searchHintText: AppLocalizations.of(context)!.search_activity_hint,
                        items: state.sportsInfo?.sportsInfoMaster.map((sport) => sport.translate(context)).toList(),
                        onFocusNodeCreated: (node) => _focusInputController = node,
                        onItemSelect: (sportName, focus) {
                          _focusInputController = focus;
                          final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                          final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                          final sportInfo = sportUpdateBloc.findSportById(sportId);
                          final info = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                          sportUpdateBloc.add(AddSportSportUpdateEvent(sportInfo: info));
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: Dimens.height12),
                      ListView.builder(
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.sportSimpleEvent?.info?.length ?? 0,
                        itemBuilder: (context, index) {
                          final sport = state.sportSimpleEvent?.info?[index];
                          while (_itemKeys.length <= index) { _itemKeys.add(GlobalKey()); }
                          return SportEventItem(
                            key: _itemKeys[index],
                            allSportsInfo: state.sportsInfo?.sportsInfoMaster ?? [],
                            sport: sport!,
                            removeSport: () => sportUpdateBloc.add(RemoveSportSportUpdateEvent(sportInfo: sport, isGoBack: () => Navigator.pop(context))),
                            editMinutes: (updatedSport) => sportUpdateBloc.add(SetMinutesSportUpdateEvent(sportInfo: updatedSport)),
                            editIntensity: (updatedSport) => sportUpdateBloc.add(SetIntensitySportUpdateEvent(sportInfo: updatedSport)),
                            showValidation: _showValidation,
                          );
                        },),
                      const SizedBox(height: Dimens.height12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                        child: GeneralButton(onTap: () {
                          if (sportUpdateBloc.validateSportList() ?? true) {
                            setState(() { _showValidation = true; });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final items = state.sportSimpleEvent?.info ?? [];
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
                          sportUpdateBloc.add(FinishUpdateSportItemSportUpdateEvent(onFinish: () => Navigator.pop(context)));
                        },
                        ),
                      ),
                    ]),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
