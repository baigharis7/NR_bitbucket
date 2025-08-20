import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/aversions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/diet_questions_header.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_checkbox_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_icon_box.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_image_checkbox.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_image_radio_button.dart';

import '../../../infrastructure/utils/constants.dart';
import '../../widgets/text_radio_button_expansible.dart';

class DietQuestionsScreen extends StatefulWidget {
  static const routeName = '/diet_question';
  const DietQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DietQuestionsScreenState();
}

class _DietQuestionsScreenState extends State<DietQuestionsScreen> {

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

    void _showDietTypesDialog({
      required BuildContext context,
      required Function onClick,
      required Function stopShowingVegetarianDiets,
    }) {
      showDialog(
        context: context,
        builder: (ctx) {
          return BlocProvider.value(
            value: bloc,
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {},
              builder: (context, state) => SimpleDialog(
                backgroundColor: Colors.transparent,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white85Percent,
                      borderRadius: BorderRadius.circular(Dimens.border18),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Text(AppLocalizations.of(context)!.diet_type, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen)),
                      const SizedBox(height: Dimens.height32),
                      ...state.dietTypes!.map((dietType) {
                        return TextRadioButtonExpansible(
                          title: dietType.name.orEmpty(),
                          explanation: '',
                          isSelected: state.profile!.dietType == dietType.id,
                          onPressed: () {
                            if (dietType.id == Vegetarian().id) {
                              bloc.add(AddVegetarianDietsOptions(showVegetarianDiets: !bloc.state.showVegetarianDiets!));
                            } else {
                              onClick.call(dietType.id);
                            }
                          },
                        );
                      }),
                    ],),
                  ),
                  const SizedBox(height: Dimens.height32),
                  GeneralButton(
                    title: AppLocalizations.of(context)!.save,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        stopShowingVegetarianDiets.call();
      });
    }

    void _showAllergensDialog(BuildContext context, Function onClick) {
      showDialog(
          context: context,
          builder: (ctx) {
            return BlocProvider.value(
              value: bloc,
              child: SimpleDialog(
                backgroundColor: Colors.transparent,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white85Percent,
                      borderRadius: BorderRadius.circular(Dimens.border18),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.allergens, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen)),
                        const SizedBox(height: Dimens.height32),
                        ...bloc.state.allergens!.map((allergen) {
                          return BlocConsumer<ProfileBloc, ProfileState>(
                            listener: (ctx, state) {},
                            builder: (ctx, state) {
                              return TextCheckboxBox(
                                title: allergen.name.orEmpty(),
                                checkboxValue: state.profile!.exclusions!.exclusions!.contains(allergen.id),
                                onChangedCheckbox: () => bloc.add(AddAllergenAction(allergenId: allergen.id!)),
                                overflow: TextOverflow.clip,
                              );
                            },
                          );
                        }),
                      ],),
                  ),
                  const SizedBox(height: Dimens.height32),
                  GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context),),
                ],
              ),
            );},
      );
    }

    void _showIntolerancesDialog(BuildContext context, Function onClick) {
      showDialog(
          context: context,
          builder: (ctx) {
            return BlocProvider.value(
              value: bloc,
              child: SimpleDialog(
                backgroundColor: Colors.transparent,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingXXLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white85Percent,
                      borderRadius: BorderRadius.circular(Dimens.border18),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.intolerances, style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge, color: AppColors.yellowishGreen)),
                        const SizedBox(height: Dimens.height32),
                        ...bloc.state.intolerances!.map((intolerance) {
                          return BlocConsumer<ProfileBloc, ProfileState>(
                            listener: (ctx, state) {},
                            builder: (stx, state) {
                              return TextCheckboxBox(
                                title: intolerance.name.orEmpty(),
                                checkboxValue: state.profile!.intolerances!.contains(intolerance.id),
                                onChangedCheckbox: () => bloc.add(AddIntolerancesAction(intoleranceId: intolerance.id!)),
                              );
                            },
                          );
                        }),
                      ],),
                  ),
                  const SizedBox(height: Dimens.height32),
                  GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context),),
                ],
              ),
            );
          },
      );
    }

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
        },
        builder: (BuildContext ctx, ProfileState state) {
          return Stack(
            children: [
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

              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimens.padding20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context, Constants.BACK),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24,),
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_name_white.png',
                      width: Dimens.width242,
                    ),
                    const SizedBox(height: Dimens.heightSmall),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimens.paddingXLarge),
                      decoration: BoxDecoration(color: AppColors.white85Percent, borderRadius: BorderRadius.circular(Dimens.border18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(ctx)!.diet,
                            style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize19, color: AppColors.yellowishGreen),
                          ),
                          const SizedBox(height: Dimens.height12),
                          Text(
                            AppLocalizations.of(ctx)!.diet_specification,
                            style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeSmall, color: AppColors.yellowishGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimens.heightXSmall),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          color: AppColors.floralWhite, // Optional
                        ),
                      child: ListTile(
                      onTap: () => _showDietTypesDialog(
                        context: ctx,
                        onClick: (id) => ctx.read<ProfileBloc>().add(SetDietTypeAction(dietType: id),),
                        stopShowingVegetarianDiets: () => bloc.add(StopShowingVegetarianDiets()),
                      ),
                      title: Text(AppLocalizations.of(ctx)!.diet_type, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black),),
                      trailing: const Icon(Icons.add_circle, size: 26, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: Dimens.heightXSmall),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          color: AppColors.floralWhite, // Optional
                        ),
                      child: ListTile(
                      onTap: () => _showAllergensDialog(ctx, (id) => ctx.read<ProfileBloc>().add(AddAllergenAction(allergenId: id)),),
                      title: Text(AppLocalizations.of(ctx)!.allergens, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black),),
                      trailing: const Icon(Icons.add_circle, size: 26, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: Dimens.heightXSmall),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          color: AppColors.floralWhite, // Optional
                        ),
                      child: ListTile(
                      onTap: () => _showIntolerancesDialog(ctx, (id) => ctx.read<ProfileBloc>().add(AddIntolerancesAction(intoleranceId: id)),),
                      title: Text(AppLocalizations.of(ctx)!.intolerances, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black),),
                      trailing: const Icon(Icons.add_circle, size: 26, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: Dimens.heightXSmall),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          color: AppColors.floralWhite, // Optional
                        ),
                      child: ListTile(
                      onTap: () => Navigator.pushNamed(context, AversionsScreen.routeName),
                      title: Text(AppLocalizations.of(ctx)!.aversions, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black),),
                      trailing: const Icon(Icons.add_circle, size: 26, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),),),
          ],);
        },
      ),
    );
  }
}
