import 'dart:convert';
import 'dart:io';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:chuck_interceptor/src/core/chuck_http_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';

abstract class ApiHelper {
  final PreferencesRepository _preferencesRepository;
  final AuthenticationService _authenticationService;
  final Chuck _chuck;

  ApiHelper(this._preferencesRepository, this._authenticationService, this._chuck);

  /// Path-only label for Crashlytics context. We deliberately drop query
  /// params (they often contain email) and host (always the same prod gateway)
  /// to keep the dashboard groupable by endpoint.
  String _endpointLabel(Uri uri) => uri.path;

  Future<Map<String, dynamic>> _handleJsonResponse(
    String method,
    Uri call,
    http.Response response,
  ) async {
    if (response.statusCode == 200) {
      try {
        return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } catch (error, stack) {
        await CrashlyticsService.record(error, stack, context: {
          'phase': 'http.$method.parse',
          'endpoint': _endpointLabel(call),
          'body_preview': response.body.length > 200 ? '${response.body.substring(0, 200)}…' : response.body,
        });
        rethrow;
      }
    }
    final errorMessage = 'status: ${response.statusCode}\nbody:${response.body}\nheaders: ${response.headers}\n';
    final httpError = HttpException(errorMessage, uri: response.request?.url);
    // 401/403 noisy on token expiry — record but with a distinct phase so the
    // dashboard can be filtered to actually-broken endpoints vs auth churn.
    final isAuth = response.statusCode == 401 || response.statusCode == 403;
    await CrashlyticsService.record(httpError, StackTrace.current, context: {
      'phase': isAuth ? 'http.$method.auth' : 'http.$method.status',
      'endpoint': _endpointLabel(call),
      'status': response.statusCode.toString(),
      'body_preview': response.body.length > 200 ? '${response.body.substring(0, 200)}…' : response.body,
    });
    throw httpError;
  }

  Future<Map<String, dynamic>> post(Uri call, dynamic body) async {
    String idToken = await _getToken();
    try {
      final httpRequestBuild = http.post(
        call,
        body: json.encode(body),
        headers: {'Authorization': idToken},
      );
      if (kDebugMode) {
        httpRequestBuild.interceptWithChuck(_chuck);
      }
      final http.Response response = await httpRequestBuild;
      return await _handleJsonResponse('post', call, response);
    } catch (error, stack) {
      if (error is HttpException) rethrow;
      await CrashlyticsService.record(error, stack, context: {
        'phase': 'http.post.transport',
        'endpoint': _endpointLabel(call),
        'error_type': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(Uri call, dynamic body) async {
    String idToken = await _getToken();
    try {
      final httpRequestBuild = http.put(
        call,
        body: json.encode(body),
        headers: {'Authorization': idToken},
      );
      if (kDebugMode) {
        httpRequestBuild.interceptWithChuck(_chuck);
      }
      final http.Response response = await httpRequestBuild;
      return await _handleJsonResponse('put', call, response);
    } catch (error, stack) {
      if (error is HttpException) rethrow;
      await CrashlyticsService.record(error, stack, context: {
        'phase': 'http.put.transport',
        'endpoint': _endpointLabel(call),
        'error_type': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(Uri call) async {
    String idToken = await _getToken();
    try {
      final httpRequestBuild = http.get(
        call,
        headers: {'Authorization': idToken},
      );
      if (kDebugMode) {
        httpRequestBuild.interceptWithChuck(_chuck);
      }
      final http.Response response = await httpRequestBuild;
      return await _handleJsonResponse('get', call, response);
    } catch (error, stack) {
      if (error is HttpException) rethrow;
      await CrashlyticsService.record(error, stack, context: {
        'phase': 'http.get.transport',
        'endpoint': _endpointLabel(call),
        'error_type': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(Uri call, dynamic body) async {
    String idToken = await _getToken();
    try {
      final httpRequestBuild = http.delete(
        call,
        body: json.encode(body),
        headers: {'Authorization': idToken},
      );
      if (kDebugMode) {
        httpRequestBuild.interceptWithChuck(_chuck);
      }
      final http.Response response = await httpRequestBuild;
      return await _handleJsonResponse('delete', call, response);
    } catch (error, stack) {
      if (error is HttpException) rethrow;
      await CrashlyticsService.record(error, stack, context: {
        'phase': 'http.delete.transport',
        'endpoint': _endpointLabel(call),
        'error_type': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  /// Like [get] but returns the raw response body as a String,
  /// useful for endpoints that return JSON arrays instead of objects.
  Future<String> getRaw(Uri call) async {
    String idToken = await _getToken();
    try {
      final httpRequestBuild = http.get(
        call,
        headers: {'Authorization': idToken},
      );
      if (kDebugMode) {
        httpRequestBuild.interceptWithChuck(_chuck);
      }
      final http.Response response = await httpRequestBuild;
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }
      final errorMessage = 'status: ${response.statusCode}\nbody:${response.body}\nheaders: ${response.headers}\n';
      final httpError = HttpException(errorMessage, uri: response.request?.url);
      await CrashlyticsService.record(httpError, StackTrace.current, context: {
        'phase': 'http.getRaw.status',
        'endpoint': _endpointLabel(call),
        'status': response.statusCode.toString(),
      });
      throw httpError;
    } catch (error, stack) {
      if (error is HttpException) rethrow;
      await CrashlyticsService.record(error, stack, context: {
        'phase': 'http.getRaw.transport',
        'endpoint': _endpointLabel(call),
        'error_type': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  Future<String> _getToken() async {
    final idToken = _preferencesRepository.getIdToken();
    if (isTokenExpired(idToken)) {
      try {
        final attributes = await _authenticationService.fetchUserAttributes();
        await _preferencesRepository.setUserCredentials(attributes);
        return attributes.userPoolTokensResult.value.idToken.toJson();
      } catch (error, stack) {
        // Refresh failed (offline, session expired, etc.). Fall back to the
        // cached (possibly expired) token so the API call surfaces a normal
        // network/auth error to the caller instead of crashing here.
        await CrashlyticsService.record(error, stack, context: {
          'phase': 'http.refreshToken',
          'error_type': error.runtimeType.toString(),
        });
        return idToken;
      }
    } else {
      return idToken;
    }
  }

}