import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/amplify_keychain_cleaner.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/amplify_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/environment/environment.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CognitoAuthenticationService implements AuthenticationService {
  CognitoAuthenticationService._();
  static final CognitoAuthenticationService instance = CognitoAuthenticationService._();

  AmplifyService? _amplifyService;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  static const _configureFlagKey = 'amplify_configure_in_progress';
  // Budget for the entire init flow (first attempt + reset + wipe + retry) is
  // 20s worst-case. Keep individual timeouts tight so a stuck configure is
  // surfaced fast while leaving headroom for legitimately slow first-launch
  // initialization.
  static const Duration _configureTimeout = Duration(seconds: 8);
  static const Duration _configureRetryTimeout = Duration(seconds: 8);
  static const Duration _resetTimeout = Duration(seconds: 2);

  /// Initialize Amplify/Cognito. Safe to call multiple times — only the first
  /// successful call does work. Self-heals around two known failure modes:
  ///   1. Native `Amplify.configure()` hangs (iOS Keychain blocking, network
  ///      stalls). A watchdog times the call out, wipes credential storage,
  ///      resets Amplify, and retries once.
  ///   2. Previous launch died mid-configure. A SharedPreferences flag detects
  ///      this on cold start and pre-emptively wipes before trying again.
  Future<CognitoAuthenticationService> initialize() async {
    if (_initialized) return this;
    final prefs = await SharedPreferences.getInstance();

    final previousAttemptHung = prefs.getBool(_configureFlagKey) ?? false;
    if (previousAttemptHung) {
      CrashlyticsService.record(
        StateError('Previous Amplify.configure() never completed — wiping state'),
        StackTrace.current,
        context: {'phase': 'amplifyConfigure', 'recovery': 'crashLoopWipe'},
      );
      await AmplifyKeychainCleaner.wipe();
    }

    await prefs.setBool(_configureFlagKey, true);

    try {
      await _attemptConfigure(timeout: _configureTimeout);
    } catch (firstError, firstStack) {
      // Watchdog or configure error fired. Wipe + reset + retry once.
      CrashlyticsService.record(firstError, firstStack, context: {
        'phase': 'amplifyConfigure',
        'attempt': '1',
        'error_type': firstError.runtimeType.toString(),
      });
      try {
        // Amplify.reset is marked @visibleForTesting upstream, but it's the
        // only API to recover from a stuck configure(). Used as a deliberate
        // last resort here.
        // ignore: invalid_use_of_visible_for_testing_member
        await Amplify.reset().timeout(_resetTimeout);
      } catch (_) {
        // Reset best-effort; if it hangs we still proceed to wipe + retry.
      }
      await AmplifyKeychainCleaner.wipe();
      _amplifyService = null;
      try {
        await _attemptConfigure(timeout: _configureRetryTimeout);
      } catch (secondError, secondStack) {
        // Retry also failed. Clear the flag so the next launch doesn't think
        // we hung again, and rethrow so callers know init didn't succeed.
        await prefs.setBool(_configureFlagKey, false);
        CrashlyticsService.record(secondError, secondStack, context: {
          'phase': 'amplifyConfigure',
          'attempt': '2',
          'error_type': secondError.runtimeType.toString(),
        });
        rethrow;
      }
    }

    await prefs.setBool(_configureFlagKey, false);
    _initialized = true;
    return this;
  }

  Future<void> _attemptConfigure({required Duration timeout}) async {
    _amplifyService = AmplifyService();
    if (!Amplify.isConfigured) {
      await _amplifyService!.addPlugin(AmplifyAuthCognito());
      await _amplifyService!
          .configure(Environment().config!.cognitoConfig.orEmpty())
          .timeout(timeout);
    }
  }

  /// Clears any local auth state (signed-in tokens, persisted Keychain items)
  /// without tearing down Amplify itself. Use before retrying signIn when the
  /// previous attempt looked like stale-state corruption. Bounded at ~4s so
  /// the surrounding signIn retry budget stays within the 20s total.
  Future<void> clearAuthState() async {
    try {
      await getAuthorization().signOut().timeout(const Duration(seconds: 2));
    } catch (_) {
      // Best-effort: signOut may throw if there's no session, or hang.
    }
    await AmplifyKeychainCleaner.wipe();
  }

  AuthCategory getAuthorization() {
    return _amplifyService!.getAuth();
  }

  @override
  Future<SignUpResult> signUp(String username, String email, String password) {

    return getAuthorization().signUp(
        username: username,
        password: password,
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.givenName: username,
          CognitoUserAttributeKey.email: email,
        },),
    );
  }

  @override
  Future<SignUpResult> sendVerificationCode(
    String confirmationCode,
    String email,
  ) async {
    return getAuthorization().confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
  }

  @override
  Future<ResendSignUpCodeResult> resendVerificationCode(String username) async {
      return await getAuthorization().resendSignUpCode(username: username);
  }

  @override
  Future<SignInResult> signIn(String username, String password) async {
    return getAuthorization().signIn(
        username: username,
        password: password,
    );
  }

  @override
  Future<CognitoAuthSession> fetchUserAttributes() async {

    final authSession = await getAuthorization().fetchAuthSession(
      options: const FetchAuthSessionOptions(forceRefresh: true),
    );
    return authSession as CognitoAuthSession;
  }

  @override
  Future<SignOutResult> signOut() => getAuthorization().signOut();

  Future<void> deleteUser() async {
    await getAuthorization().deleteUser();
  }

  @override
  Future<ResetPasswordResult> resetPassword(String username) async {
    return await getAuthorization().resetPassword(username: username);
  }

  @override
  Future<ResetPasswordResult> confirmResetPassword(String username, String newPassword, String confirmationCode) async {
    return await getAuthorization().confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode);
  }

}
