import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

/// Estimates equivalent steps from manual sport events.
///
/// Only a curated whitelist of bipedal-locomotion sports contributes — other
/// activities (cycling, swimming, weightlifting, …) produce zero step
/// contribution because "steps" is meaningless for them.
///
/// Two estimation strategies, keyed by sport id in [_stepProfiles]:
///   • metsScaled — `(METs - 1) × K × minutes`. K is sport-specific so we can
///     dampen activities where high METs come from resistance (sand, snow,
///     skipping rope) rather than higher cadence.
///   • fixedCadence — `spm × minutes`. Used for activities whose step rate is
///     largely independent of effort (stair climbing, aerobics class).
///
/// Manual entries only — events synced from Health Connect / Apple Health
/// already contribute real steps via the health platform.
int estimateStepsFromSportEvents(
  List<SportEventComplete> sportEvents,
  SportsInfoMaster sportsInfo,
) {
  final metsMap = <int, int>{};
  for (final sport in sportsInfo.sportsInfoMaster) {
    metsMap[sport.id] = sport.mets;
  }

  int totalSteps = 0;
  for (final event in sportEvents) {
    if (event.source != null && event.source != 'manual') continue;

    for (final info in event.info ?? []) {
      final profile = _stepProfiles[info.id];
      if (profile == null) continue;

      final minutes = info.minutes;
      switch (profile.strategy) {
        case _StepStrategy.metsScaled:
          final mets = metsMap[info.id] ?? 0;
          if (mets > 1) {
            totalSteps += ((mets - 1) * profile.param * minutes).toInt();
          }
          break;
        case _StepStrategy.fixedCadence:
          totalSteps += (profile.param * minutes).toInt();
          break;
      }
    }
  }
  return totalSteps;
}

enum _StepStrategy { metsScaled, fixedCadence }

class _StepProfile {
  const _StepProfile(this.strategy, this.param);
  final _StepStrategy strategy;
  final double param;
}

const _stepProfiles = <int, _StepProfile>{
  // Walking variants — standard MET-cadence relationship.
  103: _StepProfile(_StepStrategy.metsScaled, 32),  // Andar
  104: _StepProfile(_StepStrategy.metsScaled, 32),  // Caminata (fitness)
  105: _StepProfile(_StepStrategy.metsScaled, 32),  // Caminata nórdica
  106: _StepProfile(_StepStrategy.metsScaled, 32),  // Cinta de andar
  107: _StepProfile(_StepStrategy.metsScaled, 32),  // Caminar con carrito
  // Running variants — standard.
  61: _StepProfile(_StepStrategy.metsScaled, 32),   // Correr (moderado)
  62: _StepProfile(_StepStrategy.metsScaled, 32),   // Jogging
  64: _StepProfile(_StepStrategy.metsScaled, 32),   // Cinta de correr
  // Hiking — terrain ≈ pace tradeoff, standard works.
  36: _StepProfile(_StepStrategy.metsScaled, 32),   // Senderismo
  // Damped: high METs come partly from resistance, not cadence.
  63: _StepProfile(_StepStrategy.metsScaled, 22),   // Corriendo en la arena
  81: _StepProfile(_StepStrategy.metsScaled, 18),   // Esquí con raquetas (snowshoeing)
  19: _StepProfile(_StepStrategy.metsScaled, 22),   // Baile / Dancing
  22: _StepProfile(_StepStrategy.metsScaled, 25),   // Elíptica / Elliptical
  43: _StepProfile(_StepStrategy.metsScaled, 15),   // Saltar a la comba
  // Fixed cadence: step rate driven by mechanics, not METs.
  84: _StepProfile(_StepStrategy.fixedCadence, 70),  // Subir escaleras
  85: _StepProfile(_StepStrategy.fixedCadence, 75),  // Máquina de step
  0: _StepProfile(_StepStrategy.fixedCadence, 130),  // Aeróbic
  113: _StepProfile(_StepStrategy.fixedCadence, 130),// Zumba
};
