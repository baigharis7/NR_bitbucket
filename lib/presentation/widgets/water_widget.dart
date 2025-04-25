import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ani_nutri_progress_bar_widget.dart';

import '../../infrastructure/utils/dimens.dart';

class WaterWidget extends StatelessWidget {
  const WaterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border20), side: const BorderSide(color: Colors.white, width: 1,)),
      elevation: 10,
      color: AppColors.slate,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginLarge),
        child: Column(
          children: [
            const Text('Hydration', style: TextStyle(color: Colors.white, fontSize: Dimens.fontSizeLarge)),
            Row(children: [
              InkWell(onTap: () {}, child: SvgPicture.asset('assets/svg/water_minus.svg', height: 30)),
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  const Column(children: [
                    Text('2.1', style: TextStyle(color: Colors.white, fontSize: Dimens.fontSizeLarge)),
                    Text('de 1.93 liters.', style: TextStyle(color: Colors.white, fontSize: Dimens.fontSizeLarge)),
                  ],),
                  InkWell(onTap: () {}, child: SvgPicture.asset('assets/svg/agua_glass.svg',)),
                ],),
              ),
              InkWell(onTap: () {}, child: SvgPicture.asset('assets/svg/water_plus.svg', height: 30,)),
            ],),
            const AnimatedNutrientProgressBarWidget(percent: 20, height: Dimens.height12),
          ],
        ),
      ),
    );
  }

}