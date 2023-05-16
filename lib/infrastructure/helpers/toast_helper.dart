import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ToastHelper {

  Future showToast({
    required String text,
    Toast length = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 1,
    Color backgroundColor = Colors.amber,
    Color textColor = Colors.black,
    double fontSize = Dimens.fontSizeNormal,
  }) {
    return Fluttertoast.showToast(
        msg: text,
        toastLength: length,
        gravity: gravity,
        timeInSecForIosWeb: timeInSecForIosWeb,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
    );
  }

}