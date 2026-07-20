import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations_en.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations_es.dart';

/// T6 (Option A) copy regression guard: product copy must not promise
/// automatic/closed-app sync. The honest promise is sync-on-open, the
/// in-app foreground refresh, and manual Sync Now.
void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  group('health_sync_description promises no automatic background sync', () {
    test('EN', () {
      expect(en.health_sync_description.toLowerCase(),
          isNot(contains('automatic')));
      expect(en.health_sync_description.toLowerCase(),
          isNot(contains('background')));
    });

    test('ES', () {
      expect(es.health_sync_description.toLowerCase(),
          isNot(contains('automátic')));
      expect(es.health_sync_description.toLowerCase(),
          isNot(contains('segundo plano')));
    });
  });

  group('health_sync_update_hint states the honest sync triggers', () {
    test('EN mentions open-app and Sync Now', () {
      expect(en.health_sync_update_hint, contains('when you open'));
      expect(en.health_sync_update_hint, contains('Sync Now'));
    });

    test('ES mentions open-app and Sincronizar ahora', () {
      expect(es.health_sync_update_hint, contains('al abrir'));
      expect(es.health_sync_update_hint, contains('Sincronizar ahora'));
    });
  });
}
