import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/health_impact_metrics_row.dart';

/// Tests for the HealthImpactMetricsRow used inside Sleep, Steps, and
/// Hydration widgets. Each metric marker must:
///   - render the label and percentage
///   - fire the onMetricTap callback when tapped (which on the dashboard
///     opens HealthMetricDetailSheet)
void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: Container(color: Colors.black, child: child),
      ),
    );
  }

  HealthImpactMetric _stub({
    HealthMetricType type = HealthMetricType.cardiovascularHealth,
    String label = 'Cardio',
    double percentage = 50.0,
    bool isPositive = true,
    bool isNeutral = false,
  }) {
    return HealthImpactMetric(
      type: type,
      label: label,
      sublabel: 'sublabel',
      percentage: percentage,
      isPositive: isPositive,
      isNeutral: isNeutral,
    );
  }

  group('HealthImpactMetricsRow - rendering', () {
    testWidgets('renders one marker per metric', (tester) async {
      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [
          _stub(label: 'A'),
          _stub(label: 'B'),
          _stub(label: 'C'),
        ],
      )));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders the percentage rounded to integer', (tester) async {
      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [_stub(percentage: 67.4)],
      )));
      await tester.pumpAndSettle();

      // Percentage rendered as "${percentage.round()}%"
      expect(find.text('67%'), findsOneWidget);
    });

    testWidgets('renders chevron_right indicator', (tester) async {
      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [_stub()],
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('HealthImpactMetricsRow - tap callback', () {
    testWidgets('tapping a marker fires onMetricTap with that metric',
        (tester) async {
      HealthImpactMetric? tapped;
      final cardio = _stub(type: HealthMetricType.cardiovascularHealth, label: 'Cardio');
      final endurance = _stub(type: HealthMetricType.physicalEndurance, label: 'Endurance');

      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [cardio, endurance],
        onMetricTap: (m) => tapped = m,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Endurance'));
      await tester.pumpAndSettle();

      expect(tapped, isNotNull);
      expect(tapped!.type, HealthMetricType.physicalEndurance);
    });

    testWidgets('not tapping does not fire callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [_stub(label: 'A')],
        onMetricTap: (_) => called = true,
      )));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('marker is not tappable when onMetricTap is null',
        (tester) async {
      await tester.pumpWidget(_wrap(HealthImpactMetricsRow(
        metrics: [_stub(label: 'A')],
        onMetricTap: null,
      )));
      await tester.pumpAndSettle();

      // Tapping shouldn't crash even without a callback
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
    });
  });

  group('HealthImpactMarkerWidget - arrow icon by tier', () {
    testWidgets(
      'cardiovascular at 0% shows grey dash (neutral)',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.cardiovascularHealth,
            percentage: 0,
            isPositive: false,
            isNeutral: true,
          ),
        )));
        await tester.pumpAndSettle();

        // Neutral state shows Icons.remove (grey dash)
        expect(find.byIcon(Icons.remove), findsOneWidget);
      },
    );

    testWidgets(
      'cardiovascular at 22% (>=80% of 25 cap) shows green up arrow',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.cardiovascularHealth,
            percentage: 22,
            isPositive: true,
          ),
        )));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      },
    );

    testWidgets(
      'sleep concentration when isPositive=true shows green up arrow',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.concentrationFocus,
            percentage: 0,
            isPositive: true,
          ),
        )));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      },
    );

    testWidgets(
      'sleep concentration when isPositive=false shows down arrow',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.concentrationFocus,
            percentage: 30,
            isPositive: false,
          ),
        )));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      },
    );

    testWidgets(
      'cramps reduction shows down arrow when active',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.goodbyeCramps,
            percentage: 65,
            isPositive: true,
          ),
        )));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      },
    );

    testWidgets(
      'cramps reduction at 0% shows grey dash',
      (tester) async {
        await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
          metric: _stub(
            type: HealthMetricType.goodbyeCramps,
            percentage: 0,
            isPositive: false,
            isNeutral: true,
          ),
        )));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.remove), findsOneWidget);
      },
    );
  });

  group('HealthImpactMarkerWidget - onTap', () {
    testWidgets('fires onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
        metric: _stub(label: 'My Metric'),
        onTap: () => tapped = true,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Metric'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('null onTap does not crash on tap', (tester) async {
      await tester.pumpWidget(_wrap(HealthImpactMarkerWidget(
        metric: _stub(label: 'X'),
        onTap: null,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();
    });
  });
}
