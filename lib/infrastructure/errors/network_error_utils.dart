import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';

/// Detects whether an error originates from a missing/broken network
/// connection so callers can surface a connectivity message instead of a
/// generic (or misleading) one.
bool isNetworkError(Object e) {
  if (e is SocketException) return true;
  if (e is TimeoutException) return true;
  if (e is NetworkException) return true;
  // Wrapped/re-thrown errors only keep the original type in their text.
  final s = e.toString();
  return s.contains('SocketException') ||
      s.contains('NetworkException') ||
      s.contains('Failed host lookup') ||
      s.contains('Network is unreachable') ||
      s.contains('Connection refused') ||
      s.contains('Connection closed') ||
      s.contains('Connection timed out') ||
      s.contains('No address associated with hostname');
}
