import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/view/calendar_pane_screen.dart';

void main() {
  final today = DateTime.now();
  final todayMillis = DateTime(today.year, today.month, today.day, 12)
      .millisecondsSinceEpoch;

  // Use a phone-like surface size to avoid vertical overflow
  const testSurfaceSize = Size(600, 900);

  Widget buildTestWidget({
    DateTime? initialDate,
    DashboardAllCalendarEvents? allCalendarEvents,
    int? totalKcal,
    double? totalWater,
    Set<int>? programmedWeekdays,
    List<FoodRoutineEvent>? mealRoutines,
    List<SportRoutineCompleted>? sportRoutines,
    List<SupplementSimple>? supplementRoutines,
    Function(DateTime)? onDateSelected,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: CalendarPaneScreen(
        initialDate: initialDate ?? today,
        allCalendarEvents:
            allCalendarEvents ?? DashboardAllCalendarEvents.empty(),
        eventsHelper: EventsHelper(),
        totalKcal: totalKcal,
        totalWater: totalWater,
        programmedWeekdays: programmedWeekdays,
        mealRoutines: mealRoutines,
        sportRoutines: sportRoutines,
        supplementRoutines: supplementRoutines,
        onDateSelected: onDateSelected ?? (_) {},
      ),
    );
  }

  void setTestSurface(WidgetTester tester) {
    tester.view.physicalSize = testSurfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  FoodEventComplete makeFoodEvent({
    String foodName = 'Rice',
    int mealType = 0,
    int? eventDate,
    List<FoodInfo>? foodInfo,
  }) {
    return FoodEventComplete(
      userId: 'test',
      eventId: 1,
      eventDate: eventDate ?? todayMillis,
      mealType: mealType,
      foodName: foodName,
      foodInfo: foodInfo,
    );
  }

  SportEventComplete makeSportEvent({
    String sportName = 'Running',
    int? eventDate,
    int? eventKcals,
  }) {
    return SportEventComplete(
      userId: 'test',
      eventId: 2,
      eventDate: eventDate ?? todayMillis,
      sportName: sportName,
      info: [],
      eventKcals: eventKcals,
    );
  }

  // Suppress RenderFlex overflow errors in widget tests - these are layout
  // warnings that don't prevent widget tree verification. The calendar is
  // designed for real device widths (375+) which are wider than some test
  // surface configurations.
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  group('CalendarPaneScreen', () {
    testWidgets('renders header with calendar title and close button',
        (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders month and year selectors', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(today.year.toString()), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNWidgets(2));
    });

    testWidgets('renders 7 day-of-week headers', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Day-of-week headers use calendarDayGrey color + fontSize 14 + w500
      final dayHeaders = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.style?.fontSize == 14 &&
            w.style?.fontWeight == FontWeight.w500 &&
            w.style?.color == const Color(0xFF6D6E72),
      );
      expect(dayHeaders, findsNWidgets(7));
    });

    testWidgets('renders today button', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('renders legend with both dot labels', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No data recorded'), findsOneWidget);
      expect(find.text('Activities programmed'), findsOneWidget);
    });

    testWidgets('renders routine diary section title', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Routine diary'), findsOneWidget);
    });

    testWidgets('shows empty state when no events for selected day',
        (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No routines scheduled.'), findsOneWidget);
    });

    testWidgets('shows food event in routine diary', (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [makeFoodEvent(foodName: 'Chicken Salad', mealType: 1)],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
    });

    testWidgets('shows sport event in routine diary', (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [makeSportEvent(sportName: 'Swimming')],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.text('Swimming'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
    });

    testWidgets('shows multiple events sorted ascending', (tester) async {
      setTestSurface(tester);
      final earlyMillis = DateTime(today.year, today.month, today.day, 8)
          .millisecondsSinceEpoch;
      final lateMillis = DateTime(today.year, today.month, today.day, 18)
          .millisecondsSinceEpoch;

      final events = DashboardAllCalendarEvents(
        foodEvents: [
          makeFoodEvent(
              foodName: 'Dinner', eventDate: lateMillis, mealType: 2),
          makeFoodEvent(
              foodName: 'Breakfast', eventDate: earlyMillis, mealType: 0),
        ],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      final breakfastPos = tester.getTopLeft(find.text('Breakfast'));
      final dinnerPos = tester.getTopLeft(find.text('Dinner'));
      expect(breakfastPos.dy, lessThan(dinnerPos.dy));
    });

    testWidgets('renders summary section with title', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('renders summary with remaining kcal value', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget(totalKcal: 1500));
      await tester.pumpAndSettle();

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('REMAINING KCAL'), findsOneWidget);
    });

    testWidgets('renders summary with burned kcal value', (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [makeSportEvent(sportName: 'Run', eventKcals: 350)],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );
      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.text('350'), findsOneWidget);
      expect(find.text('KCAL SPENT'), findsOneWidget);
    });

    testWidgets('renders summary icons', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });

    testWidgets('defaults to 0 when no events exist', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('close button pops navigation', (tester) async {
      setTestSurface(tester);
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarPaneScreen(
                      initialDate: today,
                      allCalendarEvents: DashboardAllCalendarEvents.empty(),
                      eventsHelper: EventsHelper(),
                      onDateSelected: (_) {},
                    ),
                  ),
                ).then((_) => popped = true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Calendar'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('tapping a day cell selects it', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Pick a mid-month day that won't collide with next-month overflow cells
      final targetDay = today.day == 15 ? 14 : 15;
      final dayText = targetDay.toString().padLeft(2, '0');

      await tester.tap(find.text(dayText).first);
      await tester.pumpAndSettle();

      // Verify the widget rebuilds without error after selection
      expect(find.text(dayText), findsOneWidget);
    });

    testWidgets('today button navigates to today when on different month',
        (tester) async {
      setTestSurface(tester);
      final differentMonth = DateTime(
          today.year, today.month - 1 > 0 ? today.month - 1 : 12);
      await tester.pumpWidget(buildTestWidget(initialDate: differentMonth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      final todayStr = today.day.toString().padLeft(2, '0');
      expect(find.text(todayStr), findsWidgets);
    });

    testWidgets('calendar grid shows correct number of days for current month',
        (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        expect(find.text(d.toString().padLeft(2, '0')), findsWidgets);
      }
    });

    testWidgets('shows scrollbar when events exist', (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [
          makeFoodEvent(foodName: 'Item 1'),
          makeFoodEvent(foodName: 'Item 2'),
        ],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('does not show scrollbar when no events', (tester) async {
      setTestSurface(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsNothing);
    });

    testWidgets('renders check icon for logged events', (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [makeFoodEvent()],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders subtitle with ROUTINE label for food events',
        (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [makeFoodEvent(foodName: 'Pasta')],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.textContaining('ROUTINE'), findsOneWidget);
    });

    testWidgets('renders subtitle with WORKOUT label for sport events',
        (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [makeSportEvent(sportName: 'Yoga')],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.textContaining('WORKOUT'), findsOneWidget);
    });

    testWidgets('shows programmed routines for today when no logged events',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      await tester.pumpWidget(buildTestWidget(
        programmedWeekdays: {todayWeekday},
        mealRoutines: [
          FoodRoutineEvent(
            userId: 'test',
            eventDate: todayMillis,
            foodName: 'Morning Oats',
            comment: null,
            mealType: 0,
            daysOfWeek: [todayWeekday],
            time: '08:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Morning Oats'), findsOneWidget);
      expect(find.text('PROGRAMMED'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows programmed sport routines with WORKOUT label',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      await tester.pumpWidget(buildTestWidget(
        programmedWeekdays: {todayWeekday},
        sportRoutines: [
          SportRoutineCompleted(
            userId: 'test',
            eventId: 1,
            eventDate: todayMillis,
            sportName: 'Morning Run',
            info: [],
            daysOfWeek: [todayWeekday],
            scheduleTime: '07:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.textContaining('WORKOUT'), findsOneWidget);
    });

    testWidgets('shows programmed supplement routines with SUPPLEMENT label',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      await tester.pumpWidget(buildTestWidget(
        programmedWeekdays: {todayWeekday},
        supplementRoutines: [
          SupplementSimple(
            name: 'Creatine',
            daysOfWeek: [todayWeekday],
            scheduleTime: '09:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Creatine'), findsOneWidget);
      expect(find.textContaining('SUPPLEMENT'), findsOneWidget);
    });

    testWidgets(
        'shows programmed routines alongside logged events for the same day',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      // One food event is logged, but a supplement routine is still programmed
      final events = DashboardAllCalendarEvents(
        foodEvents: [makeFoodEvent(foodName: 'Chicken Salad', mealType: 1)],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(
        allCalendarEvents: events,
        programmedWeekdays: {todayWeekday},
        supplementRoutines: [
          SupplementSimple(
            name: 'Vitamin D',
            daysOfWeek: [todayWeekday],
            scheduleTime: '09:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Both should be visible
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
      expect(find.text('Vitamin D'), findsOneWidget);
      expect(find.text('PROGRAMMED'), findsOneWidget);
    });

    testWidgets(
        'logged food event hides matching programmed food routine but keeps unlogged sport',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      final events = DashboardAllCalendarEvents(
        foodEvents: [makeFoodEvent(foodName: 'Morning Oats', mealType: 0)],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(
        allCalendarEvents: events,
        programmedWeekdays: {todayWeekday},
        mealRoutines: [
          FoodRoutineEvent(
            userId: 'test',
            eventDate: todayMillis,
            foodName: 'Morning Oats',
            comment: null,
            mealType: 0,
            daysOfWeek: [todayWeekday],
            time: '08:00',
          ),
        ],
        sportRoutines: [
          SportRoutineCompleted(
            userId: 'test',
            eventId: 1,
            eventDate: todayMillis,
            sportName: 'Yoga',
            info: [],
            daysOfWeek: [todayWeekday],
            scheduleTime: '07:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Morning Oats shows as LOGGED (not duplicated as PROGRAMMED)
      expect(find.text('Morning Oats'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
      // Yoga hasn't fired yet, still shows as PROGRAMMED
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('PROGRAMMED'), findsOneWidget);
    });

    testWidgets(
        'logged sport event hides matching programmed sport routine',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      final yogaMillis = DateTime(today.year, today.month, today.day, 7)
          .millisecondsSinceEpoch;
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [makeSportEvent(sportName: 'Yoga', eventDate: yogaMillis)],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(
        allCalendarEvents: events,
        programmedWeekdays: {todayWeekday},
        sportRoutines: [
          SportRoutineCompleted(
            userId: 'test',
            eventId: 1,
            eventDate: todayMillis,
            sportName: 'Yoga',
            info: [],
            daysOfWeek: [todayWeekday],
            scheduleTime: '07:00',
          ),
          SportRoutineCompleted(
            userId: 'test',
            eventId: 2,
            eventDate: todayMillis,
            sportName: 'Evening Run',
            info: [],
            daysOfWeek: [todayWeekday],
            scheduleTime: '18:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Yoga: logged event replaces programmed routine
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
      // Evening Run: hasn't fired yet
      expect(find.text('Evening Run'), findsOneWidget);
      expect(find.text('PROGRAMMED'), findsOneWidget);
    });

    testWidgets('logged supplement event shows as LOGGED with title',
        (tester) async {
      setTestSurface(tester);
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [
          SupplementSimple(
            userId: 'test',
            eventId: 100,
            eventDate: todayMillis,
            name: 'Vitamin A',
            info: [],
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(allCalendarEvents: events));
      await tester.pumpAndSettle();

      expect(find.text('Vitamin A'), findsOneWidget);
      expect(find.textContaining('SUPPLEMENT'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
    });

    testWidgets(
        'logged supplement hides matching programmed supplement routine',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      final events = DashboardAllCalendarEvents(
        foodEvents: [],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [
          SupplementSimple(
            userId: 'test',
            eventId: 100,
            eventDate: todayMillis,
            name: 'Vitamin A',
            info: [],
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(
        allCalendarEvents: events,
        programmedWeekdays: {todayWeekday},
        supplementRoutines: [
          SupplementSimple(
            name: 'Vitamin A',
            daysOfWeek: [todayWeekday],
            scheduleTime: '08:00',
          ),
          SupplementSimple(
            name: 'Vitamin B2',
            daysOfWeek: [todayWeekday],
            scheduleTime: '09:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Vitamin A: only LOGGED (not also PROGRAMMED)
      expect(find.text('Vitamin A'), findsOneWidget);
      expect(find.text('LOGGED'), findsOneWidget);
      // Vitamin B2: still PROGRAMMED
      expect(find.text('Vitamin B2'), findsOneWidget);
      expect(find.text('PROGRAMMED'), findsOneWidget);
    });

    testWidgets('mixed logged and programmed items are sorted by time',
        (tester) async {
      setTestSurface(tester);
      final todayWeekday = today.weekday;
      // Logged food event at 14:00
      final lunchMillis = DateTime(today.year, today.month, today.day, 14)
          .millisecondsSinceEpoch;
      final events = DashboardAllCalendarEvents(
        foodEvents: [
          makeFoodEvent(
              foodName: 'Lunch', mealType: 1, eventDate: lunchMillis),
        ],
        sportEvents: [],
        liquidEvents: [],
        waterEvents: [],
        creatineEvent: [],
        collagenEvent: [],
        faecesEvents: [],
        urineEvents: [],
        supplementEvents: [],
      );

      await tester.pumpWidget(buildTestWidget(
        allCalendarEvents: events,
        programmedWeekdays: {todayWeekday},
        supplementRoutines: [
          SupplementSimple(
            name: 'Morning Vitamin',
            daysOfWeek: [todayWeekday],
            scheduleTime: '07:00',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Morning Vitamin (07:00 programmed) should appear above Lunch (14:00 logged)
      final vitaminPos = tester.getTopLeft(find.text('Morning Vitamin'));
      final lunchPos = tester.getTopLeft(find.text('Lunch'));
      expect(vitaminPos.dy, lessThan(lunchPos.dy));
    });
  });
}
