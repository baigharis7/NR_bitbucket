import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
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
import 'package:nutrenaissance_flutter/presentation/widgets/add_item_name_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

import '../../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../../infrastructure/helpers/date_time_helper.dart';
import '../../../../infrastructure/helpers/remove_diac.dart';
import '../../../sportevent/view/sport_event_item.dart';
import '../../../widgets/box_type_radio_text_widget.dart';

class CreateNewSportFavoriteScreen extends StatefulWidget {
  static const routeName = '/create_new_sport_favorite';

  const CreateNewSportFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewSportFavoriteScreenState();

}

class _CreateNewSportFavoriteScreenState extends State<CreateNewSportFavoriteScreen> {
  TextEditingController _sportInputController = TextEditingController();
  late FocusNode _focusInputController;
  int filteredListLength = 0;

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
      builder: (ctx) => AddItemNameDialog(
        title: '${AppLocalizations.of(context)!.spor_name}:',
        onNameChange: (String sportName) => onNameChange.call(sportName),
        onSave: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
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

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((timeStamp) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        if (arguments is AddSportFavorite) {
          bloc.add(SetDataFromDetailNaviAction(favoritesSport: arguments));
        }
      }
    });
  }

  @override
  void dispose() {
    _sportInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CreateNewSportFavoriteBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventsHelper = EventsHelper();

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
                      AppLocalizations.of(context)!.add_favorite,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeXXLarge,
                      ),
                    ),
                  ),
                ),
              ),
              body: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: Dimens.marginLarge,
                    horizontal: Dimens.marginXLarge,
                ),
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
                        _focusInputController = focusNode;
                        return TextField(
                          decoration: InputDecoration(
                            fillColor: Colors.black,
                            labelText: AppLocalizations.of(context)!.enter,
                            suffixIcon: IconButton(
                              icon: textEditingController.text != ''
                                  ? const Icon(Icons.highlight_remove, color: Colors.black,)
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
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => _sportInputController.text.isNotEmptyOrNull() && _sportInputController.text.length > 2 ? Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal), child: Text('$filteredListLength: ' '${filteredListLength > 1 ? AppLocalizations.of(context)!.items_found : AppLocalizations.of(context)!.item_found}',)) : Container(),
                          onChanged: (value) {
                            setState(() {
                              textEditingController;
                            });
                          },
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '' || textEditingValue.text.length < 3) return const Iterable<String>.empty();
                        final filteredList =  state.sportsInfo!.sportsInfoMaster.map((sport) => sport.translate(context)).where((String option) => removeDiacritics(option).toLowerCase().contains(removeDiacritics(textEditingValue.text.toLowerCase())));
                        filteredListLength = filteredList.length;
                        return filteredList;
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - Dimens.margin_60, maxHeight: Dimens.heightXXLarge), // Adjust the width as needed
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: ListView(
                                  children: ListTile.divideTiles(
                                    context: context,
                                    tiles: options.map((String option) {
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    }),
                                  ).toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onSelected: (sportName) {
                        final sportIntensities = eventsHelper.getChosenSportIntensities(sportName, state.sportsInfo!, currentLanguage);
                        final sportId = eventsHelper.getSportIdByName(sportName, state.sportsInfo!, currentLanguage);
                        final sportInfo = bloc.findSportById(sportId);
                        final info  = AddSportFavInfo(id: sportId, name_en: sportInfo.en, name_es: sportInfo.es, intensity: sportIntensities == 1 ? 0 : null, timeStart: DateTime.now().millisecondsSinceEpoch);
                        bloc.add(AddFavSportAction(info));
                        _sportInputController.text = '';
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          ...state.info.orEmpty().map((sport) => /*SportEventItem(
                            sportIntensities: eventsHelper.getChosenSportIntensities(sport.translate(context), state.sportsInfo!, currentLanguage),
                            sport: AddSportFavInfo(id: sport.id, name_es: sport.name_es, name_en: sport.name_en, timeStart: sport.timeStart, intensity: sport.intensity, minutes: sport.minutes),
                            removeSport: () { bloc.add(RemoveSportFavAction(addSportFavInfo: sport)); },
                            editMinutes: (updatedSport) { bloc.add(UpdateMinutesSportFavAction(addSportFavInfo: AddSportFavInfo(id: updatedSport.id, minutes: updatedSport.minutes, intensity: updatedSport.intensity, timeStart: updatedSport.timeStart, name_en: updatedSport.name_en, name_es: updatedSport.name_es))); },
                            editIntensity: (updatedSport) { bloc.add(UpdateIntensitySportFavAction(addSportFavInfo: AddSportFavInfo(id: updatedSport.id, minutes: updatedSport.minutes, intensity: updatedSport.intensity, timeStart: updatedSport.timeStart, name_en: updatedSport.name_en, name_es: updatedSport.name_es))); },
                            )*/ Container()
                            ,),
                          if (state.info.orEmpty().isNotEmpty) IconButton(
                            onPressed: () { _focusInputController.requestFocus(); },
                            icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                          ),
                          if (state.info.orEmpty().isNotEmpty) BoxTypeRadioTextWidget(
                              onPressed: () => bloc.add(UpdateCreateRoutineAction()),
                              isSelected:
                              state.isCreateRoutine ?? false,
                              showHourDays: true,
                              routineHour: DateTimeHelper.formatTimeOfDay(state.routineHour, context),
                              changeHour: (timeOfDay) => bloc.add(UpdateRoutineHourAction(timeOfDay: timeOfDay)),
                              changeDate: (dateTime) => bloc.add(UpdateRoutineDateAction(dateTime: dateTime)),
                              routineDay: DateTimeHelper.formatDateTimeToDay(state.routineDate),
                              title: AppLocalizations.of(context)!
                                  .create_routine,),
                        ],),
                      ),
                    ),
                    RoundedCustomButton(
                      onPressed: () {
                        if (bloc.validateFavSportList() ?? true) return;
                          if (state.info.orEmpty().isNotEmpty) {
                            if (state.isCreateRoutine ?? false) {
                              if(state.routineHour.isNull() || state.routineDate.isNull()) return;

                              if (state.info.orEmpty().length > 1) {
                                showAddFavoriteDialog(
                                  context: ctx,
                                  onNameChange: (String sportName) => bloc.add(UpdateSportFavoriteNameAction(favoriteSportName: sportName)),
                                  onFinish: () => bloc.add(FinishCreateRoutineAction(onFinish: () => _showConfirmationDialog(context))),
                                  onResetInfo: () => bloc.add(ResetFavoriteSportInfoAction()),
                                );
                              } else {
                                bloc.add(FinishSportFavWithoutCreateRoutineAction(onFinish: () => _showConfirmationDialog(context), context: context));
                              }
                            } else {
                              // state.favoriteSportName = state.info.orEmpty().map((sport) => sport.translate(context)).toString();
                              bloc.add(FinishSportFavWithoutCreateRoutineAction(onFinish: () => _showConfirmationDialog(context), context: context));
                            }
                          }
                      },
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