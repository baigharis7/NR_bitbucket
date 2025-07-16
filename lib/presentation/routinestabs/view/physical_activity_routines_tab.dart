import 'package:flutter/cupertino.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';

class PhysicalActivityRoutinesTab extends StatelessWidget {
  const PhysicalActivityRoutinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Physical Activity routines will be shown here....', style: AppTextStyles.subtitle2, textAlign: TextAlign.center),
      ],);
  }

}