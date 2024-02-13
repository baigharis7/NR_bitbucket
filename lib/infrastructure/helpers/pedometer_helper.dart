import 'package:pedometer/pedometer.dart';

class PedometerManager {
  final Stream<StepCount> _pedometerCountStream;
  Function (StepCount)? _onData;
  Function (dynamic)? _onError;

  static PedometerManager init({Stream<StepCount>? pedometerCount}) {
    pedometerCount ??= Pedometer.stepCountStream;
    return PedometerManager._(pedometerCount);
  }

  PedometerManager._(this._pedometerCountStream);

  PedometerManager onData(Function(StepCount) onData) {
    _onData = onData;

    return this;
  }

  PedometerManager onError(Function(dynamic) onError) {
    _onError = onError;

    return this;
  }

  void execute() {
    _pedometerCountStream.listen(_onData, onError: _onError, cancelOnError: true);
  }

}