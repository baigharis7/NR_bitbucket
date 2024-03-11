import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recipe_steps_item.dart';

import '../recipe_detail/bloc/recipe_detail_bloc.dart';

class RecipeSteps extends StatefulWidget {
  const RecipeSteps({super.key});

  @override
  State<RecipeSteps> createState() => _RecipeStepsState();
}

class _RecipeStepsState extends State<RecipeSteps> {
  late RecipeDetailBloc recipeDetailBloc;

  @override
  void initState() {
    recipeDetailBloc = BlocProvider.of<RecipeDetailBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var position = 1;
    return Scaffold(
      body: BlocProvider.value(
          value: recipeDetailBloc,
          child: BlocConsumer<RecipeDetailBloc, RecipeDetailState>(
            listener: (BuildContext context, RecipeDetailState state) {},
            builder: (context, state) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                child: Column(children: [
                  Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall), child: Text(state.uploadRecipeFavorite?.itemRecipe.translate(context) ?? '', style: const TextStyle(fontSize: Dimens.fontSizeLarge), textAlign: TextAlign.center,)),
                  Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: AppColors.errorRed, size: Dimens.heightXXSmall +5,),
                        const Text(' - 245', style: TextStyle(fontSize: Dimens.fontSizeSmall),),
                        const SizedBox(width: Dimens.widthXXXXSmall + 10),
                        const Icon(Icons.timer_sharp, color: AppColors.mountainMeadow, size: Dimens.heightXXSmall +5,),
                        Text(' - ${state.uploadRecipeFavorite?.itemRecipe.time} min', style: const TextStyle(fontSize: Dimens.fontSizeSmall)),
                  ],),
                  ...state.uploadRecipeFavorite?.itemRecipe.steps_es?.steps[0].subSteps.orEmpty().map((step) => RecipeStepItem(step: step, position: position++,)) ?? [],
                ],),),
          ),),
    );
  }
}
