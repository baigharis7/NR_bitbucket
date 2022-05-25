import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic> decodeToken(String token) => JwtDecoder.decode(token);

int getTokenExpirationTime(String token) => JwtDecoder.getExpirationDate(token).millisecondsSinceEpoch;

bool isTokenExpired(String token) => JwtDecoder.isExpired(token);

String? getEmailFromToken(String? idToken) {
  if (idToken == null) {
    return null;
  } else {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = json.decode(ascii.decode(base64.decode(base64.normalize(idToken.split(".")[1]))));
      return payload['email'];

    } catch (error) {
        rethrow;
    }
  }
}