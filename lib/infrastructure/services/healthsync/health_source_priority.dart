import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';

/// Shared source-priority policy for cross-source aggregation (steps, sleep,
/// …). LOCKED CONTRACT: the ordering below is relied on verbatim by every
/// domain that reuses this class — do not reorder without updating all
/// callers.
///
/// Highest priority first: dedicated body-worn wearables (Apple Watch,
/// Garmin, Fitbit, Polar) — the device most likely to have actually counted
/// the steps. Next, Samsung Health, since on Android it commonly carries a
/// paired Galaxy Watch's data and should outrank the phone's own platform
/// app. Then the platform's own apps (Health Connect app, Apple Health app).
/// Then Google Fit, which typically just mirrors/aggregates other sources
/// rather than measuring anything itself. Unknown sources rank last.
///
/// Note: the coarse [HealthSyncSourceCategory] buckets (wearable /
/// thirdPartyApp / phone / unknown) used for diagnostics labelling are
/// derived from this fine-grained order for display purposes only — they
/// are NOT the priority signal used here.
class HealthSourcePriority {
  const HealthSourcePriority();

  static const List<HealthSourceCategory> _order = [
    HealthSourceCategory.appleWatch,
    HealthSourceCategory.garmin,
    HealthSourceCategory.fitbit,
    HealthSourceCategory.polar,
    HealthSourceCategory.samsungHealth,
    HealthSourceCategory.healthConnectApp,
    HealthSourceCategory.appleHealthApp,
    HealthSourceCategory.googleFit,
    HealthSourceCategory.unknown,
  ];

  /// Index of [category] in the priority order — lower is higher priority.
  /// Every [HealthSourceCategory] value is present in [_order], so this never
  /// returns -1.
  int rank(HealthSourceCategory category) {
    final index = _order.indexOf(category);
    assert(index != -1, 'HealthSourceCategory.$category missing from _order');
    return index;
  }

  /// The highest-priority category among [categories] (min rank).
  /// Deterministic and independent of iteration order. Callers must guard
  /// against an empty iterable — asserts here rather than throwing.
  HealthSourceCategory highestOf(Iterable<HealthSourceCategory> categories) {
    assert(categories.isNotEmpty, 'highestOf requires a non-empty iterable');
    return categories.reduce(
      (best, next) => rank(next) < rank(best) ? next : best,
    );
  }
}

/// Maps a fine-grained [HealthSourceCategory] to the coarse
/// [HealthSyncSourceCategory] bucket used in sanitized diagnostics metadata.
HealthSyncSourceCategory coarseSourceCategory(HealthSourceCategory category) {
  switch (category) {
    case HealthSourceCategory.appleWatch:
    case HealthSourceCategory.garmin:
    case HealthSourceCategory.fitbit:
    case HealthSourceCategory.polar:
      return HealthSyncSourceCategory.wearable;
    case HealthSourceCategory.samsungHealth:
    case HealthSourceCategory.googleFit:
      return HealthSyncSourceCategory.thirdPartyApp;
    case HealthSourceCategory.healthConnectApp:
    case HealthSourceCategory.appleHealthApp:
      return HealthSyncSourceCategory.phone;
    case HealthSourceCategory.unknown:
      return HealthSyncSourceCategory.unknown;
  }
}
