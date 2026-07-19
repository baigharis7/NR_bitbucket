import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';

/// Shared source-priority policy for cross-source aggregation (steps, sleep,
/// …). LOCKED CONTRACT: the ordering below is relied on verbatim by every
/// domain that reuses this class — do not reorder without updating all
/// callers.
///
/// Highest priority first: a device worn on the body outranks a phone-side
/// app, which outranks a third-party account sync, which outranks an
/// unrecognized source.
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
