import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

import '../../infrastructure/utils/dimens.dart';

class IngestedSpentWidget extends StatelessWidget {
  final String svg;
  final String title;
  final int value;
  const IngestedSpentWidget({super.key, required this.svg, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      SvgPicture.asset(svg, width: 24, height: 24,),
      const SizedBox(height: 4),
      Text(value.toString(), style: AppTextStyles.radioCanadaBig.copyWith(fontSize: 28, fontWeight: FontWeight.w400)),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(title.toUpperCase(), textAlign: TextAlign.center, style: AppTextStyles.radioCanadaBig.copyWith(fontSize: 12, fontWeight: FontWeight.w400)),
      ),
    ],);
  }

}