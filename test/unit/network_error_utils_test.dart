import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/network_error_utils.dart';

void main() {
  group('isNetworkError', () {
    test('returns true for SocketException', () {
      expect(isNetworkError(const SocketException('no route to host')), isTrue);
    });

    test('returns true for TimeoutException', () {
      expect(isNetworkError(TimeoutException('timed out')), isTrue);
    });

    test('returns true for Amplify NetworkException', () {
      expect(isNetworkError(const NetworkException('no connectivity')), isTrue);
    });

    test('returns true for wrapped errors that only keep the type in text', () {
      expect(
        isNetworkError(Exception('SocketException: Failed host lookup: api')),
        isTrue,
      );
      expect(isNetworkError(Exception('Network is unreachable')), isTrue);
      expect(isNetworkError(Exception('Connection refused')), isTrue);
    });

    test('returns false for non-network errors', () {
      expect(isNetworkError(const FormatException('bad json')), isFalse);
      expect(isNetworkError(Exception('Incorrect username or password.')), isFalse);
      expect(isNetworkError(StateError('oops')), isFalse);
      expect(isNetworkError('some random string'), isFalse);
    });
  });
}
