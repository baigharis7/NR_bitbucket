import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/health_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/registry_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class RegistryScreen extends StatefulWidget {
  const RegistryScreen({Key? key}) : super(key: key);

  static const routeName = '/registry_screen';

  @override
  State<StatefulWidget> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen> {

  Future<void> _showObjectivesBottomDialog(BuildContext context) async {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (ctx) => const ObjectivesDialog(),
    );
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(InitializeStateFromRegistryAction(context: context));
    super.initState();
  }

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
            builder: (ctx, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.marginXLarge,
                          horizontal: Dimens.marginXLarge,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimens.marginXLarge,
                          horizontal: Dimens.marginXLarge,
                        ),
                        child: Image.asset('assets/images/logo_name_black.png'),
                    ),
                    RegistryCard(
                      title: AppLocalizations.of(ctx)!.objectives,
                      onClick: () =>_showObjectivesBottomDialog(ctx),
                    ),
                    RegistryCard(
                      title: AppLocalizations.of(ctx)!.body_measurements,
                      onClick: () => Navigator.pushNamed(context, GeneralQuestionsScreen.routeName),
                    ),
                    RegistryCard(
                      title: AppLocalizations.of(ctx)!.medical_history,
                      onClick: () => Navigator.pushNamed(context, HealthQuestionsScreen.routeName),
                    ),
                    RegistryCard(
                      title: AppLocalizations.of(ctx)!.diet,
                      onClick: () => Navigator.pushNamed(context, DietQuestionsScreen.routeName),
                    ),
                    RegistryCard(
                      title: AppLocalizations.of(ctx)!.physical_activity,
                      onClick: () => Navigator.pushNamed(context, PhysicalActivityScreen.routeName),
                    ),
                    RoundedCustomButton(
                      onPressed: () {
                        if (bloc.areMandatoryFieldsComplete()) {
                          bloc.add(FinishProfileAction(nextScreen: () => Navigator.popAndPushNamed(context, ProfileScreen.routeName)));
                        } else {
                          showErrorSnackBar(context, bloc.buildMandatoryFieldsNotCompletedMessage(context));
                        }
                      },
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
