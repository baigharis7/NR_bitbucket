import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_radio_button_expansible.dart';

import '../../../infrastructure/utils/app_color.dart';

class PhysicalActivityScreen extends StatefulWidget {
  static const routeName = '/physical_activity';

  const PhysicalActivityScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhysicalActivityScreen();
}

class _PhysicalActivityScreen extends State<PhysicalActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

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
                body: SafeArea(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimens.padding20),
                child: Column(
                  children: [
                    Container(alignment: AlignmentDirectional.centerStart, child: IconButton(onPressed: () => Navigator.pop(context, Constants.BACK), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,))),
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
                          AppLocalizations.of(context)!.physical_activity,
                          style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize19, color: AppColors.yellowishGreen),
                        ),
                        const SizedBox(height: Dimens.height12),
                        Text(
                          AppLocalizations.of(context)!.activity_type,
                          style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeSmall, color: AppColors.yellowishGreen),
                        ),
                        const SizedBox(height: Dimens.height12),
                        ...state.activityTypes!.map((activityType) {
                          return TextRadioButtonExpansible(
                            title: activityType.typeName.orEmpty(),
                            explanation: activityType.explanation.orEmpty(),
                            isSelected: state.profile!.occupationActivityFactor == activityType.physicalActivityFactor,
                            onPressed: () => bloc.add(SetActivityTypeAction(activityType: activityType.physicalActivityFactor!)),
                          );
                        }),
                      ],),
                    ),
                    const SizedBox(height: Dimens.height32),
                    GeneralButton(title: AppLocalizations.of(context)!.save, onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
                ),),
            ],
          );
        },
      ),
    );
  }
}
