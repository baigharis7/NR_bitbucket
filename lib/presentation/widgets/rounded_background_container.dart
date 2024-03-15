import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/utils/dimens.dart';

class RoundedBackgroundContainer extends StatelessWidget {
  final Widget widget;
  final Function? onTap;
  final EdgeInsetsGeometry? margin;

  const RoundedBackgroundContainer({super.key, this.margin, required this.widget, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(Dimens.paddingNormal),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
          shape: BoxShape.rectangle,
        ),
        child: widget,
      ),
      onTap: () => onTap?.call(),
    );
  }
}
