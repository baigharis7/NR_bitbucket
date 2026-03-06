import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/favorites_recent_toggle.dart';

void main() {
  Widget buildTestWidget({
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: FavoritesRecentToggle(
          selectedIndex: selectedIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  group('FavoritesRecentToggle', () {
    testWidgets('renders two buttons with correct labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 0,
        onTap: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('FAVORITES'), findsOneWidget);
    });

    testWidgets('selected button (index 0) uses yellowishGreen59 background', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 0,
        onTap: (_) {},
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      // Find the container with yellowishGreen59 decoration
      final greenContainers = containers.where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppColors.yellowishGreen59;
        }
        return false;
      });
      expect(greenContainers.isNotEmpty, isTrue);
    });

    testWidgets('unselected button uses butter59 background', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 0,
        onTap: (_) {},
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      final butterContainers = containers.where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppColors.butter59;
        }
        return false;
      });
      expect(butterContainers.isNotEmpty, isTrue);
    });

    testWidgets('tapping Recent button calls onTap with 0', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 1,
        onTap: (index) => tappedIndex = index,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('RECENT'));
      expect(tappedIndex, 0);
    });

    testWidgets('tapping Favorites button calls onTap with 1', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 0,
        onTap: (index) => tappedIndex = index,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAVORITES'));
      expect(tappedIndex, 1);
    });

    testWidgets('selected index 1 shows Favorites as selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        selectedIndex: 1,
        onTap: (_) {},
      ));
      await tester.pumpAndSettle();

      // The Favorites text should be white (selected) and Recent should be yellowishGreen (unselected)
      final recentText = tester.widget<Text>(find.text('RECENT'));
      final favoritesText = tester.widget<Text>(find.text('FAVORITES'));
      expect(recentText.style?.color, AppColors.yellowishGreen);
      expect(favoritesText.style?.color, Colors.white);
    });
  });
}
