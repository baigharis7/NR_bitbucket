import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/dimens.dart';

class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  static const TextStyle hh = TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize28, color: Colors.white);
  static const TextStyle h3 = TextStyle(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize21, color: Colors.white);
  static const TextStyle subtitle2 = TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeNormal, color: Colors.white);

  //fonts
  static const TextStyle merriWeather = TextStyle(fontFamily: 'MerriWeather', fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeNormal, color: Colors.white,);

  static const TextStyle radioCanadaBig = TextStyle(fontFamily: 'RadioCanadaBig', fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeNormal, color: Colors.white,);
}