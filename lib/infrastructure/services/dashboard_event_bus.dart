import 'dart:async';

enum DataChangedCategory { food, water, liquid, sport, supplement, fecesUrine, profile, steps }

class DashboardEventBus {
  DashboardEventBus._();
  static final instance = DashboardEventBus._();

  final _controller = StreamController<DataChangedCategory>.broadcast();
  Stream<DataChangedCategory> get stream => _controller.stream;

  void notify(DataChangedCategory category) => _controller.add(category);
}
