import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/interactor/login/fetch_user_attributes_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/token_utils.dart';

abstract class ApiHelper {

  final GetIdTokenInteractor _getIdTokenInteractor;
  final FetchUserAttributesInteractor _fetchUserAttributesInteractor;

  ApiHelper(this._getIdTokenInteractor, this._fetchUserAttributesInteractor);

  Future<Map<String, dynamic>> post(Uri call, dynamic body) async {
    String idToken = await _getToken();
    final http.Response response = await http.post(
        call,
        body: json.encode(body),
        headers: {
          'Authorization': idToken
        }
    );

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
        });

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
    String idToken = _getIdTokenInteractor.execute();
    if (isTokenExpired(idToken)) {
      await _fetchUserAttributesInteractor.execute();
      return _getIdTokenInteractor.execute();
    } else {
      return idToken;
    }
  }

}