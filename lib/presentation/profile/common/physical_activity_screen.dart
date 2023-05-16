import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/text_radio_button_expansible.dart';

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

    return SafeArea(
      child: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<ProfileBloc, ProfileState>(
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
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginLarge),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        height: 59,
                        width: 59,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginXXLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: Dimens.marginSmall),
                            child: Text(
                              AppLocalizations.of(context)!.physical_activity,
                              style: const TextStyle(
                                fontSize: Dimens.fontSizeXXLarge,
                              ),
                            ),
                          ),
                          Image.asset('assets/icon/sport_icon.png')
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: Dimens.marginNormal,
                        bottom: Dimens.marginLarge,
                        top: Dimens.marginXLarge,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.activity_type,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...state.activityTypes!.map((activityType) {
                      return TextRadioButtonExpansible(
                        title: activityType.typeName.orEmpty(),
                        explanation: activityType.explanation.orEmpty(),
                        isSelected: state.profile!.occupationActivityFactor! == activityType.physicalActivityFactor,
                        onPressed: () => bloc.add(SetActivityTypeAction(activityType: activityType.physicalActivityFactor!)),
                      );
                    }),
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, bottom: Dimens.marginXLarge),
                      child: RoundedCustomButton(onPressed: () => Navigator.pop(context)),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
