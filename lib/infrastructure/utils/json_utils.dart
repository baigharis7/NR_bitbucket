import 'dart:convert';

import 'package:flutter/material.dart';

class JsonUtils {
  final BuildContext context;

  JsonUtils({required this.context});

  AssetBundle _getAssetBundle() {
    return DefaultAssetBundle.of(context);
  }

  Future<Map<String, dynamic>> readJson(String source) async {
    String data = await _getAssetBundle().loadString(source);
    final Map<String, dynamic> jsonResult = jsonDecode(data);

    return jsonResult;
  }

}