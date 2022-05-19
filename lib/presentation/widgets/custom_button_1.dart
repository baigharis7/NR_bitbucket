import 'package:flutter/material.dart';


class CustomButton1 extends StatelessWidget {
  final String message;
  final Function action;
  final ButtonStyle? style;
  final bool isPushed;

  const CustomButton1({Key? key, required this.message, required this.action, this.style, this.isPushed = false}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style ?? ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        primary: isPushed ? Colors.amber[100] : Colors.amber,
        side: const BorderSide(style: BorderStyle.solid),
      ),
      child: Text(message),
      onPressed: () => action.call());
  }
}