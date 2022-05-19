import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic> decodeToken(String token) => JwtDecoder.decode(token);

int getTokenExpirationTime(String token) => JwtDecoder.getExpirationDate(token).millisecondsSinceEpoch;

bool isTokenExpired(String token) => JwtDecoder.isExpired(token);