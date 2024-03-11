import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart' as master;
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RecipeStepItem extends StatelessWidget {
  final String step;
  final int position;
  const RecipeStepItem({super.key, required this.step, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal,/* vertical: Dimens.marginNormal*/),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingSmall - 6,),
                decoration: const BoxDecoration(
                    color: AppColors.mountainMeadow,
                    shape: BoxShape.circle,),
                child: Text('$position', style: const TextStyle(color: Colors.white),),
              ),
              Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginLarge), child: Text(step))),
            ],
          ),
          // Row(children: [
          //   Expanded(child: Image.asset('assets/images/step_img.png', height: 267, fit: BoxFit.fill,)),
          //   Expanded(child: Image.asset('assets/images/step_vid.png', height: 267, fit: BoxFit.fill,)),
          // ],),
        ],
      ),
    );
  }
}
