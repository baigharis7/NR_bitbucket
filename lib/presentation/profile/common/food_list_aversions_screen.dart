import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/model/aversions_ui_model.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/utils/app_color.dart';

class FoodListAversionsScreen extends StatefulWidget {

  static const routeName = '/food_list_aversions';

  const FoodListAversionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodListAversionsScreenState();

}

class _FoodListAversionsScreenState extends State<FoodListAversionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    final foodGroup = ModalRoute.of(context)!.settings.arguments as FoodGroup;

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        },
        builder: (context, state) {
          return Stack(children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'), // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimens.padding20),
              child: Column(
                children: [
                  Container(alignment: AlignmentDirectional.centerStart, child: IconButton(onPressed: () => Navigator.pop(context,), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,))),
                  Image.asset(
                    'assets/images/logo_name_white.png',
                    width: Dimens.width242,
                  ),
                  const SizedBox(height: Dimens.heightSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white85Percent,
                      borderRadius: BorderRadius.circular(Dimens.border18),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.diet,
                          style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize19, color: AppColors.yellowishGreen),
                        ),
                        const SizedBox(height: Dimens.height12),
                        Text(
                          AppLocalizations.of(context)!.diet_desc,
                          style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeSmall, color: AppColors.yellowishGreen),
                        ),
                        const SizedBox(height: Dimens.height12),
                        ...foodGroup.foodsList.map((food) => TextCheckboxBox(
                          title: food.name,
                          checkboxValue: state.profile!.foodAversions!.contains(food.id),
                          onChangedCheckbox: () => bloc.add(ManageAversionsAction(foodId: food.id)),
                        ),),
                      ],),
                  ),
                  const SizedBox(height: Dimens.height32),
                ],
              ),
            )),),
          ],);
        },
      ),
    );
  }

}