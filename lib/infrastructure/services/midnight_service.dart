import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Singleton service that detects when the local clock crosses midnight.
/// Emits the new date (at 00:00) on a broadcast [Stream].
class MidnightService {
  MidnightService._();
  static final instance = MidnightService._();

  final _controller = StreamController<DateTime>.broadcast();
  Stream<DateTime> get stream => _controller.stream;

  Timer? _timer;
  DateTime _lastKnownDate = _today();

  /// Injectable clock for testing. Defaults to [DateTime.now].
  @visibleForTesting
  DateTime Function() clock = () => DateTime.now();

  /// Call once at app startup (e.g. DashboardScreen.initState).
  void start() {
    _lastKnownDate = _todayFromClock();
    _scheduleNextMidnight();
  }

  /// Call on app lifecycle resume to handle backgrounded-past-midnight.
  /// Idempotent — safe to call multiple times on the same day.
  void checkNow() {
    final today = _todayFromClock();
    if (today != _lastKnownDate) {
      _lastKnownDate = today;
      _controller.add(today);
      _timer?.cancel();
      _scheduleNextMidnight();
    }
  }

  void _scheduleNextMidnight() {
    _timer?.cancel();
    final now = clock();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // +500ms buffer to ensure we're past the midnight boundary
    final duration =
        nextMidnight.difference(now) + const Duration(milliseconds: 500);
    _timer = Timer(duration, () {
      _lastKnownDate = _todayFromClock();
      _controller.add(_lastKnownDate);
      _scheduleNextMidnight();
    });
  }

  DateTime _todayFromClock() {
    final now = clock();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @visibleForTesting
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

/// Mixin for [State] subclasses on detail/summary screens.
/// Shows a non-intrusive snackbar when midnight crosses.
/// Does NOT change the screen's date or reload data.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with MidnightToastMixin {
///   @override
///   void initState() {
///     super.initState();
///     subscribeMidnight();
///   }
///   @override
///   void dispose() {
///     unsubscribeMidnight();
///     super.dispose();
///   }
/// }
/// ```
mixin MidnightToastMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<DateTime>? _midnightSub;

  void subscribeMidnight() {
    _midnightSub = MidnightService.instance.stream.listen((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.new_day_message ??
                  "It's a new day! Go back to see today's data.",
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void unsubscribeMidnight() {
    _midnightSub?.cancel();
  }
}
