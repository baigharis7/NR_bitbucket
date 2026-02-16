import 'dart:convert';

import 'package:chuck_interceptor/chuck.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/sync/sync_queue_entry.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/api_helper.dart';

class SyncQueueService extends ApiHelper {
  final Box<SyncQueueEntry> _box;
  static const _maxRetries = 10;

  SyncQueueService(
    PreferencesRepository preferencesRepository,
    AuthenticationService authenticationService,
    Chuck chuck,
    this._box,
  ) : super(preferencesRepository, authenticationService, chuck);

  void enqueue(String path, dynamic body) {
    _box.add(SyncQueueEntry(
      path: path,
      bodyJson: jsonEncode(body),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> processQueue() async {
    final entries = _box.values.toList();
    for (final entry in entries) {
      try {
        final uri = Uri.https(
          Environment().config!.baseUrl,
          '${Environment().config!.distributionPath}${entry.path}',
        );
        await post(uri, jsonDecode(entry.bodyJson));
        await entry.delete();
      } catch (_) {
        entry.retryCount++;
        if (entry.retryCount >= _maxRetries) {
          await entry.delete();
        } else {
          await entry.save();
        }
      }
    }
  }

  int get pendingCount => _box.length;
}
