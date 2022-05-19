import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_id_token_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/http/http_helper.dart';

class HttpHelperImpl extends HttpHelper {
  final GetIdTokenInteractor getIdTokenInteractor;

  HttpHelperImpl({required this.getIdTokenInteractor});

  @override
  Future<Map<String, dynamic>> post(Uri call, dynamic body) async {
    String idToken = getIdTokenInteractor.execute();
    Uri uriAuthenticated = Uri.parse('${call.toString()}$idToken');
    final response = await http.post(
        uriAuthenticated,
        body: body
    );

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse;
  }
}