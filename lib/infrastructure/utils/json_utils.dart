import 'dart:convert';
import 'package:flutter/cupertino.dart';

class JsonUtils {
  final BuildContext context;

  JsonUtils({required this.context});

  AssetBundle getAssetBundle() {
    return DefaultAssetBundle.of(context);
  }

  Future<Map<String, dynamic>> readJson(String source) async {

    String data = await getAssetBundle().loadString(source);
    final Map<String, dynamic> jsonResult = jsonDecode(data);

    return jsonResult;
  }

}