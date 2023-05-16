import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_actions.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_state.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/add_event_calendar_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_list_item.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {

  static const routeName = '/calendar_screen';

  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTimeHelper().provideCurrentDate();
  DateTime _focusedDay = DateTimeHelper().provideCurrentDate();

  @override
  void initState() {
    final bloc = BlocProvider.of<CalendarBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CalendarBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<CalendarBloc, CalendarState>(
          listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
            },
            builder: (ctx, state) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                  ),
                  titleSpacing: Dimens.marginNormal,
                  title: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: Dimens.marginNormal),
                        child: Text(
                          AppLocalizations.of(context)!.calendar,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: Dimens.fontSizeLarge,
                          ),
                        ),
                      ),
                      Container(
                        height: 28,
                        margin: const EdgeInsets.only(left: Dimens.marginNormal),
                        child: const Icon(Icons.calendar_month),
                      )
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: TableCalendar(
                          firstDay: bloc.provideFirstDay(),
                          focusedDay: _focusedDay,
                          lastDay: bloc.provideLastDay(),
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              bloc.add(SelectDayEventsActions(selectedDay: _selectedDay));
                            });
                          },
                          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                          ),
                          eventLoader: (date) {
                            return bloc.getEventsForDay(date);
                          },
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                                return Container(
                                  margin: const EdgeInsets.only(left: Dimens.marginSmall, bottom: Dimens.marginXSmall),
                                  child: Icon(
                                    events.isEmpty ? Icons.clear : Icons.done,
                                    color: events.isEmpty ? Colors.red : Colors.green,
                                    size: 19,
                                  ),
                                );
                            },
                          ),
                          headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                          ),
                        ),
                      ),
                      if (state.dayEvents!.isEmpty) Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                        child: Card(
                          color: Colors.yellow[200],
                          child: SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.empty_events_calendar,
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontSize: Dimens.fontSizeLarge-2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...state.dayEvents!.map((dayEvent) => EventListItem(
                        title: bloc.getEventTitle(ctx, dayEvent),
                        onEdit: () => Navigator.pushNamed(
                          context,
                          bloc.getRouteNameByEventTypeForEditing(dayEvent).orEmpty(),
                          arguments: bloc.getArgumentsToEditEvent(dayEvent),
                        ).then((value) {
                          bloc.add(RefreshEventsAction(selectedDay: _selectedDay));
                        }),
                        onFavorite: () => Navigator.pushNamed(
                          context,
                          bloc.getRouteNameByEventTypeForFavorites(dayEvent.runtimeType).orEmpty(),
                          arguments: bloc.getArgumentsAndTransformIntoFavorites(dayEvent),
                        ).then((value) {
                          bloc.add(RefreshEventsAction(selectedDay: _selectedDay));
                        }),
                      ),).toList(),
                      if (state.dayEvents!.isEmpty) Column(
                        children: [
                          AddEventCalendarButton(
                            title: AppLocalizations.of(context)!.add_food,
                            onPressedButton: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: _selectedDay).then((value) => bloc.add(InitializeStateAction())),
                          ),
                          AddEventCalendarButton(
                            title: AppLocalizations.of(context)!.add_sport_calendar,
                            onPressedButton: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: _selectedDay).then((value) => bloc.add(InitializeStateAction())),
                          ),
                          AddEventCalendarButton(
                            title: AppLocalizations.of(context)!.add_liquid_calendar,
                            onPressedButton: () => Navigator.pushNamed(context, AddLiquidEventScreen.routeName, arguments: _selectedDay).then((value) => bloc.add(InitializeStateAction())),
                          ),
                        ],
                      )
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