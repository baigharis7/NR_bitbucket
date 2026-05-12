import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

class SyncQueueService extends ApiHelper {
  final Box<SyncQueueEntry> _box;

  /// Base delay doubles each retry: 2s → 4s → 8s → 16s → … capped at 5 min.
  static const _baseDelaySeconds = 2;
  static const _maxDelaySeconds = 300; // 5 minutes
  static const _maxRetries = 10;

  /// Once the retry budget is spent, wait this long before trying again so a
  /// permanently-broken server payload doesn't loop-spam the network and
  /// Crashlytics on every processQueue cycle.
  static const _exhaustedCooldownMs = 60 * 60 * 1000; // 1 hour

  /// Only re-report an exhausted entry to Crashlytics this often, so one
  /// stuck entry doesn't generate dozens of duplicate events per day.
  static const _reportDedupeMs = 24 * 60 * 60 * 1000; // 24 hours

  /// Drop an entry whose server upload has failed for this long. The local
  /// copy of the user's data is unaffected — only the server-side mirror
  /// is sacrificed.
  static const _maxEntryAgeMs = 7 * 24 * 60 * 60 * 1000; // 7 days

  SyncQueueService(
    PreferencesRepository preferencesRepository,
    AuthenticationService authenticationService,
    Chuck chuck,
    this._box,
  ) : super(preferencesRepository, authenticationService, chuck);

  void enqueue(String path, dynamic body, {String method = 'POST'}) {
    _box.add(SyncQueueEntry(
      path: path,
      bodyJson: jsonEncode(body),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      method: method,
    ));
  }

  void enqueueDelete(String path, dynamic body) {
    enqueue(path, body, method: 'DELETE');
  }

  Future<void> processQueue() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final entries = _box.values.toList();

    for (final entry in entries) {
      // Stop trying entries the server has rejected for a week — local data
      // is already persisted in Hive; only the server mirror is sacrificed.
      if (now - entry.createdAt > _maxEntryAgeMs) {
        _reportToCrashlytics(entry, Exception('SyncQueue entry abandoned: age exceeded'), permanent: true);
        await entry.delete();
        continue;
      }

      // Skip entries whose backoff hasn't elapsed yet
      if (entry.nextRetryAt > now) continue;

      try {
        final uri = Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}${entry.path}',
        );
        final body = jsonDecode(entry.bodyJson);
        if (entry.method == 'DELETE') {
          await delete(uri, body);
        } else {
          await post(uri, body);
        }
        // Success — remove from queue
        await entry.delete();
      } on HttpException catch (e) {
        final statusCode = _extractStatusCode(e);
        // Auth failures (401/403) are transient: the access token is expired
        // and will be refreshed by ApiHelper on the next outgoing request.
        // Throttling (429) is also transient. Everything else in the 4xx
        // range is a permanent client error.
        final isTransient = statusCode == null
            || statusCode >= 500
            || statusCode == 401
            || statusCode == 403
            || statusCode == 429;
        if (isTransient) {
          _scheduleRetry(entry, e);
        } else {
          debugPrint('SyncQueue: dropping entry ${entry.path} — permanent error $statusCode');
          _reportToCrashlytics(entry, e, permanent: true);
          await entry.delete();
        }
      } catch (e) {
        // Network error, timeout, etc. — schedule retry
        _scheduleRetry(entry, e);
      }
    }
  }

  void _scheduleRetry(SyncQueueEntry entry, dynamic error) {
    entry.retryCount++;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (entry.retryCount >= _maxRetries) {
      // Report to Crashlytics, but only if we haven't reported this same
      // entry recently — prior implementation reset nextRetryAt to 0 and
      // re-reported every processQueue cycle, generating dozens of duplicate
      // events per stuck entry.
      if (now - entry.lastReportedAt > _reportDedupeMs) {
        _reportToCrashlytics(entry, error);
        entry.lastReportedAt = now;
      }
      // Long cool-down rather than immediate re-attempt. Entry will be
      // dropped entirely once its age exceeds _maxEntryAgeMs in processQueue.
      entry.nextRetryAt = now + _exhaustedCooldownMs;
      entry.save();
      return;
    }

    final delaySeconds = min(
      _baseDelaySeconds * pow(2, entry.retryCount - 1).toInt(),
      _maxDelaySeconds,
    );
    entry.nextRetryAt = now + (delaySeconds * 1000);
    entry.save();
    debugPrint('SyncQueue: retry #${entry.retryCount} for ${entry.path} in ${delaySeconds}s');
  }

  void _reportToCrashlytics(SyncQueueEntry entry, dynamic error, {bool permanent = false}) {
    CrashlyticsService.record(
      error is Error ? error : Exception('SyncQueue failure: $error'),
      error is Error ? error.stackTrace : StackTrace.current,
      context: {
        'action': 'SyncQueue ${permanent ? "permanent failure" : "max retries reached"}',
        'path': entry.path,
        'method': entry.method,
        'retryCount': entry.retryCount.toString(),
        'createdAt': DateTime.fromMillisecondsSinceEpoch(entry.createdAt).toIso8601String(),
        'age': '${((DateTime.now().millisecondsSinceEpoch - entry.createdAt) / 1000 / 60).round()} min',
      },
    );
  }

  /// Extracts the HTTP status code from an HttpException message.
  int? _extractStatusCode(HttpException e) {
    final match = RegExp(r'status:\s*(\d+)').firstMatch(e.message);
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }

  int get pendingCount => _box.length;
}
