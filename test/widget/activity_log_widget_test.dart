import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/activity_log_widget.dart';

void main() {
  Widget buildTestWidget({
    List<SportEventComplete> sportEvents = const [],
    VoidCallback? onAdd,
    VoidCallback? onTap,
    bool showHealthSyncPrompt = false,
    VoidCallback? onHealthSyncTap,
    VoidCallback? onHealthSyncDismiss,
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
      home: Scaffold(
        body: SingleChildScrollView(
          child: ActivityLogWidget(
            sportEvents: sportEvents,
            onAdd: onAdd ?? () {},
            onTap: onTap ?? () {},
            showHealthSyncPrompt: showHealthSyncPrompt,
            onHealthSyncTap: onHealthSyncTap,
            onHealthSyncDismiss: onHealthSyncDismiss,
          ),
        ),
      ),
    );
  }

  SportEventComplete makeSportEvent({
    String sportName = 'Running',
    int eventKcals = 200,
    String? source,
  }) {
    return SportEventComplete(
      userId: 'test',
      eventId: 1,
      eventDate: DateTime.now().millisecondsSinceEpoch,
      sportName: sportName,
      source: source,
      eventKcals: eventKcals,
      info: [],
    );
  }

  group('ActivityLogWidget', () {
    testWidgets('renders activity log title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Activity Log'), findsOneWidget);
    });

    testWidgets('shows "No activity recorded." when no sport events', (tester) async {
      await tester.pumpWidget(buildTestWidget(sportEvents: []));
      await tester.pumpAndSettle();

      expect(find.text('No activity recorded.'), findsOneWidget);
    });

    testWidgets('does not show "No activity recorded." when sport events exist', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        sportEvents: [makeSportEvent()],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No activity recorded.'), findsNothing);
    });

    testWidgets('shows sport event name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        sportEvents: [makeSportEvent(sportName: 'Swimming')],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Swimming'), findsOneWidget);
    });

    testWidgets('shows add button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('add button calls onAdd callback', (tester) async {
      bool addCalled = false;
      await tester.pumpWidget(buildTestWidget(
        onAdd: () => addCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle));
      expect(addCalled, isTrue);
    });

    group('Health Sync Prompt', () {
      testWidgets('shows health sync prompt when showHealthSyncPrompt is true', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          showHealthSyncPrompt: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Enable Health Data Sync'), findsOneWidget);
      });

      testWidgets('does not show health sync prompt when showHealthSyncPrompt is false', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          showHealthSyncPrompt: false,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Enable Health Data Sync'), findsNothing);
      });

      testWidgets('health sync prompt has dismiss button', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          showHealthSyncPrompt: true,
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });

      testWidgets('dismiss button calls onHealthSyncDismiss', (tester) async {
        bool dismissed = false;
        await tester.pumpWidget(buildTestWidget(
          showHealthSyncPrompt: true,
          onHealthSyncDismiss: () => dismissed = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.cancel_outlined));
        expect(dismissed, isTrue);
      });

      testWidgets('tapping prompt area calls onHealthSyncTap', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(buildTestWidget(
          showHealthSyncPrompt: true,
          onHealthSyncTap: () => tapped = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Enable Health Data Sync'));
        expect(tapped, isTrue);
      });

      testWidgets('shows prompt alongside empty activity state', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          sportEvents: [],
          showHealthSyncPrompt: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('No activity recorded.'), findsOneWidget);
        expect(find.text('Enable Health Data Sync'), findsOneWidget);
      });

      testWidgets('shows prompt alongside sport events', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          sportEvents: [makeSportEvent(sportName: 'Yoga')],
          showHealthSyncPrompt: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Yoga'), findsOneWidget);
        expect(find.text('Enable Health Data Sync'), findsOneWidget);
      });
    });
  });
}
