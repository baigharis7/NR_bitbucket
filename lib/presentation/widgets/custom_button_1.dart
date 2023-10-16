import 'package:flutter/material.dart';

import '../../infrastructure/utils/dimens.dart';

class CustomButton1 extends StatelessWidget {
  final String message;
  final Function action;
  final ButtonStyle? style;
  final bool isSelected;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton1({
    Key? key,
    required this.message,
    required this.action,
    this.style,
    this.isSelected = false,
    this.textColor,
    this.borderColor,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSmall,
      child: ElevatedButton(
        style: style ?? ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: borderColor == null ? 0.0 : 1.0,
            ),
          ),
          backgroundColor: isSelected ? Colors.grey[400] : Colors.white,
        ),
        child: Text(
          message,
          overflow: TextOverflow.clip,
          maxLines: 2,
          style: TextStyle(
              color: textColor ?? Colors.black,
            fontSize: Dimens.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => action.call(),
      ),
    );
  }
}