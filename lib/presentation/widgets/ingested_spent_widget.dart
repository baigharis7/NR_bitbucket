import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../infrastructure/utils/dimens.dart';

class IngestedSpentWidget extends StatelessWidget {
  final String svg;
  final String title;
  final int value;
  const IngestedSpentWidget({super.key, required this.svg, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SvgPicture.asset(svg,),
      const SizedBox(height: Dimens.height12),
      Text(value.toString(), style: const TextStyle(fontSize: Dimens.fontSizeXXLarge, color: Colors.white, fontWeight: FontWeight.bold)),
      Text(title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: Dimens.fontSizeSmall, color: Colors.white)),
    ],);
  }

}