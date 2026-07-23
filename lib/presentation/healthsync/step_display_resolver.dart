import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';

/// Resolves the step count to show on the dashboard.
///
/// Policy: the sensor is authoritative whenever health sync is enabled.
/// Adding the estimated steps on top of the sensor total would double-count
/// activities the sensor already recorded, since the estimator intentionally
/// lets manually-logged events through. Estimated steps are therefore only
/// used on the no-sync path. When sync is enabled but no sensor value is
/// available yet, the displayed count is 0 — it never falls back to the
/// estimate.
int resolveDisplayedStepCount(HealthSyncState state) {
  return state.isSyncEnabled ? (state.todayStepCount ?? 0) : state.estimatedStepCount;
}
