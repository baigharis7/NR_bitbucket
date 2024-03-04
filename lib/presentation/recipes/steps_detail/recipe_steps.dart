import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recipe_steps_item.dart';

class RecipeSteps extends StatefulWidget {
  const RecipeSteps({super.key});

  @override
  State<RecipeSteps> createState() => _RecipeStepsState();
}

class _RecipeStepsState extends State<RecipeSteps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge), child: Column(children: [
        Text('pumpkin cream'.toUpperCase(), style: const TextStyle(fontSize: Dimens.fontSizeLarge)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.favorite, color: AppColors.errorRed, size: 15,),
          Text(' - 245', style: TextStyle(fontSize: Dimens.fontSizeSmall),),
          SizedBox(width: Dimens.widthXXXXSmall + 10),
          Icon(Icons.timer_sharp, color: AppColors.mountainMeadow, size: 15,),
          Text(' - 15 min', style: TextStyle(fontSize: Dimens.fontSizeSmall)),
        ]),
        ...['1','2','3'].map((e) => RecipeStepItem())
      ])),
    );
  }
}
