import 'dart:convert';
import 'package:chuck_interceptor/chuck.dart';
import 'package:chuck_interceptor/core/chuck_http_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/authentication/authentication_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';

abstract class ApiHelper {
  final PreferencesRepository _preferencesRepository;
  final AuthenticationService _authenticationService;
  final Chuck _chuck;

  ApiHelper(this._preferencesRepository, this._authenticationService, this._chuck);

  Future<Map<String, dynamic>> post(Uri call, dynamic body) async {
    String idToken = await _getToken();
    // final httpRequestBuild = http.post(
    //   call,
    //   body: json.encode(body),
    //   headers: {
    //     'Authorization': idToken
    //   },
    // );
    // if (kDebugMode) {
    //   httpRequestBuild.interceptWithChuck(_chuck);
    // }
    // final http.Response response = await httpRequestBuild;
    final http.Response response = await http.post(
        call,
        body: json.encode(body),
        headers: {
          'Authorization': idToken
        },
    ).interceptWithChuck(_chuck);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse;
      } catch (error) {
        rethrow;
      }
    } else {
      throw (response);
    }
  }

  Future<Map<String, dynamic>> get(Uri call) async {
    String idToken = await _getToken();
    final http.Response response = await http.get(
        call,
        headers: {
          'Authorization': idToken
        },
    ).interceptWithChuck(_chuck);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse;
      } catch (error) {
        rethrow;
      }
    } else {
      throw response;
    }
  }

  Future<Map<String, dynamic>> delete(Uri call, dynamic body) async {
    String idToken = await _getToken();
    final http.Response response = await http.delete(
      call,
      body: json.encode(body),
      headers: {
        'Authorization': idToken
      },
    ).interceptWithChuck(_chuck);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse;
      } catch (error) {
        rethrow;
      }
    } else {
      throw response;
    }
  }

  Future<String> _getToken() async {
    final idToken = _preferencesRepository.getIdToken();
    if (isTokenExpired(idToken)) {
      final attributes = await _authenticationService.fetchUserAttributes();
      _preferencesRepository.setUserCredentials(attributes);
      return attributes.userPoolTokens!.idToken;
    } else {
      return idToken;
    }
  }

}