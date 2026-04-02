import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/cognito_authentication_service.dart';

/// A lazy wrapper around [CognitoAuthenticationService] that defers
/// Amplify/Cognito initialization until [initialize] is called.
///
/// Created in [main] (instant, no network) and passed to all API objects.
/// The actual Cognito init happens on the splash screen.
/// Any API call made before initialization completes will wait — not crash.
class LateAuthenticationService implements AuthenticationService {
  static final LateAuthenticationService instance = LateAuthenticationService._();

  LateAuthenticationService._();

  final Completer<CognitoAuthenticationService> _completer = Completer<CognitoAuthenticationService>();
  CognitoAuthenticationService? _service;

  /// Whether Cognito has been successfully initialized.
  bool get isInitialized => _service != null;

  /// The underlying service, available after [initialize] completes.
  CognitoAuthenticationService? get service => _service;

  /// Initialize Cognito/Amplify. Call from the splash screen.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize({Duration timeout = const Duration(seconds: 10)}) async {
    if (_service != null) return;

    FirebaseCrashlytics.instance.log('LateAuthService: starting Cognito init');
    final cognitoService = await CognitoAuthenticationService.init()
        .timeout(timeout);
    _service = cognitoService;
    if (!_completer.isCompleted) {
      _completer.complete(cognitoService);
    }
    FirebaseCrashlytics.instance.log('LateAuthService: Cognito init complete');
  }

  /// Waits for initialization to complete, with a safety timeout.
  /// If splash init failed and login hasn't re-initialized yet,
  /// this prevents API callers from hanging forever.
  Future<CognitoAuthenticationService> _waitForService() async {
    if (_service != null) return _service!;
    return _completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException(
        'Auth service not initialized — Cognito init may have failed',
        const Duration(seconds: 15),
      ),
    );
  }

  @override
  Future<CognitoAuthSession> fetchUserAttributes() async {
    final s = await _waitForService();
    return s.fetchUserAttributes();
  }

  @override
  Future<SignInResult> signIn(String username, String password) async {
    final s = await _waitForService();
    return s.signIn(username, password);
  }

  @override
  Future<SignUpResult> signUp(String username, String email, String password) async {
    final s = await _waitForService();
    return s.signUp(username, email, password);
  }

  @override
  Future<SignUpResult> sendVerificationCode(String confirmationCode, String email) async {
    final s = await _waitForService();
    return s.sendVerificationCode(confirmationCode, email);
  }

  @override
  Future<ResendSignUpCodeResult> resendVerificationCode(String username) async {
    final s = await _waitForService();
    return s.resendVerificationCode(username);
  }

  @override
  Future<SignOutResult> signOut() async {
    final s = await _waitForService();
    return s.signOut();
  }

  @override
  Future<ResetPasswordResult> resetPassword(String username) async {
    final s = await _waitForService();
    return s.resetPassword(username);
  }

  @override
  Future<ResetPasswordResult> confirmResetPassword(String username, String newPassword, String confirmationCode) async {
    final s = await _waitForService();
    return s.confirmResetPassword(username, newPassword, confirmationCode);
  }

  Future<void> deleteUser() async {
    final s = await _waitForService();
    return s.deleteUser();
  }
}
