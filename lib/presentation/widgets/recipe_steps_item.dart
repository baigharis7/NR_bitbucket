import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RecipeStepItem extends StatefulWidget {
  const RecipeStepItem({super.key});

  @override
  State<RecipeStepItem> createState() => _RecipeStepsState();
}

class _RecipeStepsState extends State<RecipeStepItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingSmall - 6,),
                decoration: BoxDecoration(
                    color: AppColors.mountainMeadow,
                    borderRadius: BorderRadius.circular(50),),
                child: Text(
                  '1',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginLarge), child: Text('Cut the pumpkin. Cut the skin off and scrape seeds out. Cut into chunks.'))),
            ],
          ),
          Row(children: [
            Expanded(child: Image.asset('assets/images/step_img.png', height: 267, fit: BoxFit.fill,)),
            Expanded(child: Image.asset('assets/images/step_vid.png', height: 267, fit: BoxFit.fill,)),
          ],),
        ],
      ),
    );
  }
}
