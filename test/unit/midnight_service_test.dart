import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';

/// Creates a fresh MidnightService for testing (not the singleton).
MidnightService _createService() {
  // Access the private constructor via a test-only factory.
  // Since the constructor is private, we test via the singleton but reset state
  // using the clock injection.
  return MidnightService.instance;
}

void main() {
  group('MidnightService', () {
    late MidnightService service;

    setUp(() {
      service = _createService();
      // Reset to a known state
      service.clock = () => DateTime(2026, 2, 26, 10, 0, 0);
    });

    tearDown(() {
      service.clock = () => DateTime.now();
    });

    test('checkNow emits new date when day has changed', () async {
      // Start on Feb 26
      service.clock = () => DateTime(2026, 2, 26, 23, 59, 0);
      service.start();

      final emissions = <DateTime>[];
      final sub = service.stream.listen(emissions.add);

      // Simulate next day
      service.clock = () => DateTime(2026, 2, 27, 0, 1, 0);
      service.checkNow();

      // Allow stream to deliver
      await Future.delayed(Duration.zero);

      expect(emissions.length, 1);
      expect(emissions.first, DateTime(2026, 2, 27));

      await sub.cancel();
    });

    test('checkNow does not emit on same day', () async {
      service.clock = () => DateTime(2026, 2, 26, 10, 0, 0);
      service.start();

      final emissions = <DateTime>[];
      final sub = service.stream.listen(emissions.add);

      // Same day, different time
      service.clock = () => DateTime(2026, 2, 26, 23, 59, 59);
      service.checkNow();

      await Future.delayed(Duration.zero);

      expect(emissions, isEmpty);

      await sub.cancel();
    });

    test('checkNow is idempotent — double call on same new day emits only once', () async {
      service.clock = () => DateTime(2026, 2, 26, 23, 59, 0);
      service.start();

      final emissions = <DateTime>[];
      final sub = service.stream.listen(emissions.add);

      service.clock = () => DateTime(2026, 2, 27, 0, 5, 0);
      service.checkNow();
      service.checkNow();

      await Future.delayed(Duration.zero);

      expect(emissions.length, 1);

      await sub.cancel();
    });

    test('checkNow detects multi-day gap (backgrounded for 2 days)', () async {
      service.clock = () => DateTime(2026, 2, 25, 20, 0, 0);
      service.start();

      final emissions = <DateTime>[];
      final sub = service.stream.listen(emissions.add);

      // Jump ahead 2 days
      service.clock = () => DateTime(2026, 2, 27, 8, 0, 0);
      service.checkNow();

      await Future.delayed(Duration.zero);

      expect(emissions.length, 1);
      expect(emissions.first, DateTime(2026, 2, 27));

      await sub.cancel();
    });

    test('start sets lastKnownDate and does not emit', () async {
      service.clock = () => DateTime(2026, 2, 26, 12, 0, 0);

      final emissions = <DateTime>[];
      final sub = service.stream.listen(emissions.add);

      service.start();

      await Future.delayed(Duration.zero);

      expect(emissions, isEmpty);

      await sub.cancel();
    });

    test('stream is broadcast — multiple listeners receive the event', () async {
      service.clock = () => DateTime(2026, 2, 26, 23, 0, 0);
      service.start();

      final emissions1 = <DateTime>[];
      final emissions2 = <DateTime>[];
      final sub1 = service.stream.listen(emissions1.add);
      final sub2 = service.stream.listen(emissions2.add);

      service.clock = () => DateTime(2026, 2, 27, 0, 1, 0);
      service.checkNow();

      await Future.delayed(Duration.zero);

      expect(emissions1.length, 1);
      expect(emissions2.length, 1);

      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
