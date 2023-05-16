import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic> decodeToken(String token) => JwtDecoder.decode(token);

int getTokenExpirationTime(String token) => JwtDecoder.getExpirationDate(token).millisecondsSinceEpoch;

bool isTokenExpired(String token) => JwtDecoder.isExpired(token);

dynamic decodeIdToken(String? idToken) {
  if (idToken == null) {
    return null;
  } else {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = json.decode(ascii.decode(base64.decode(base64.normalize(idToken.split('.')[1]))));
      return payload;
    } catch (error) {
      rethrow;
    }
  }
}

String getEmailFromToken(String? idToken) {
  try {
    final decodedToken = decodeIdToken(idToken);
    return decodedToken['email'];
  } catch (error) {
      rethrow;
  }
}

bool isUserConfirmedFromToken(String? idToken) {
  try {
    final decodedToken = decodeIdToken(idToken);
    return decodedToken['email_verified'] as bool;
  } catch (error) {
      rethrow;
  }
}