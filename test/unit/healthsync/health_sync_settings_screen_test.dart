import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_settings_screen.dart';

class MockHealthSyncBloc extends MockBloc<HealthSyncEvent, HealthSyncState>
    implements HealthSyncBloc {}

/// T6 (Option A): the settings screen must set honest sync expectations —
/// the update hint (sync-on-open / in-use refresh / manual Sync Now) is
/// always visible and no copy on the screen claims automatic sync.
void main() {
  late MockHealthSyncBloc bloc;

  setUp(() {
    bloc = MockHealthSyncBloc();
  });

  Future<void> pumpScreen(WidgetTester tester, {required Locale locale}) async {
    whenListen(
      bloc,
      const Stream<HealthSyncState>.empty(),
      initialState: HealthSyncState(isAvailable: true, isSyncEnabled: true),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<HealthSyncBloc>.value(
          value: bloc,
          child: const HealthSyncSettingsScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the sync-expectation hint in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));

    expect(find.textContaining('when you open'), findsOneWidget);
    expect(find.textContaining('Sync Now'), findsWidgets);
    expect(find.textContaining('automatically'), findsNothing);
  });

  testWidgets('shows the sync-expectation hint in Spanish', (tester) async {
    await pumpScreen(tester, locale: const Locale('es'));

    expect(find.textContaining('al abrir'), findsOneWidget);
    expect(find.textContaining('Sincronizar ahora'), findsWidgets);
    expect(find.textContaining('automáticamente'), findsNothing);
  });
}
