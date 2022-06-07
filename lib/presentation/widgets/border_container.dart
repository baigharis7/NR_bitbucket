import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class BorderContainer extends StatelessWidget {
  final Color borderColor;
  final Color backgroundColor;
  final Widget? child;

  const BorderContainer({Key? key, this.borderColor = Colors.red, this.backgroundColor = Colors.white, required this.child}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.marginSmall),
      decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            width: Dimens.borderNormal,
            color: borderColor
        ),
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: child,
    );
  }

}