import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RoundedBorderBox extends StatelessWidget {
  final Widget child;
  const RoundedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.paddingXLarge,),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(Dimens.border15),
      ),
      child: child,
    );
  }
}
