import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/popup_menu_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/health_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/profile_option_with_graphic_and_add.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

import '../../../dashboard/bloc/dashboard_actions.dart';
import '../../../widgets/custom_bottom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreen();

}

class _ProfileScreen extends State<ProfileScreen> {

  void _showObjectivesBottomModalSheet({required BuildContext context, required Function onSaveChanges}) {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (ctx) => const ObjectivesDialog(),
    ).then((userProfileModel) => onSaveChanges.call());
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(InitializeStateFromProfileAction(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProfileBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
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
          builder:  (ctx, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                titleSpacing: Dimens.marginNormal,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.profile,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                actions: [
                  PopupMenuHelper().createPopupMenuWith(
                    model: [
                      PopupMenuItemModel(
                        value: 0,
                        title: AppLocalizations.of(context)!.log_out,
                        onPressed: () => bloc.add(PerformLogOutAction(goToLogin: () => Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false,))),
                      ),
                      PopupMenuItemModel(
                        value: 1,
                        title: AppLocalizations.of(context)!.data_and_privacy,
                        onPressed: () => {},
                      ),
                      PopupMenuItemModel(
                        value: 2,
                        title: AppLocalizations.of(context)!.help,
                        onPressed: () => {},
                      ),
                    ],
                    buttonImage: Image.asset('assets/icon/profile_icon.png', height: 29, width: 29,),

                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileOptionWithGraphicAndAdd(
                      title: AppLocalizations.of(context)!.objectives,
                      widget: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          ...?state.filteredObjectives?.map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingNormal),
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              decoration: BoxDecoration(color:AppColors.mountainMeadow, borderRadius: BorderRadius.circular(5)),
                              child: Text(e.translate(context), style: const TextStyle(color: Colors.white,), maxLines: 1, overflow: TextOverflow.ellipsis,))),
                        ],),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.all(Dimens.marginLarge),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey[300],
                      //     shape: BoxShape.rectangle,
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      //   alignment: Alignment.center,
                      //   child:
                      //   Text(
                      //     '${bloc.getNumberOfObjectives()} ${AppLocalizations.of(context)!.objectives}',
                      //     style: TextStyle(
                      //       fontSize: Dimens.fontSizeLarge,
                      //       color: Colors.red[300],
                      //     ),
                      //   ),
                      // ),
                      onAdd: () => _showObjectivesBottomModalSheet(
                        context: context,
                        onSaveChanges: () => bloc.add(SaveChangesAction()),
                      ),
                    ),
                    ProfileOptionWithGraphicAndAdd(
                      title: AppLocalizations.of(context)!.body_measurements,
                      widget: FillHorizontalBar(
                        fractionToFill: bloc.getPhysicalCharacteristicsFillPercentage(),
                        height: 9,
                      ),
                      onAdd: () => Navigator.pushNamed(context, GeneralQuestionsScreen.routeName).then((_) => bloc.add(SaveChangesAction())),
                    ),
                    ProfileOptionWithGraphicAndAdd(
                      title: AppLocalizations.of(context)!.medical_history,
                      widget: FillHorizontalBar(
                        fractionToFill: bloc.getMedicalSituationFillPercentage(),
                        height: 9,
                      ),
                      onAdd: () => Navigator.pushNamed(context, HealthQuestionsScreen.routeName).then((value) => bloc.add(SaveChangesAction())),
                    ),
                    ProfileOptionWithGraphicAndAdd(
                      title: AppLocalizations.of(context)!.diet,
                      widget: FillHorizontalBar(
                        fractionToFill: bloc.getDietPercentageFill(),
                        height: 9,
                      ),
                      onAdd: () => Navigator.pushNamed(context, DietQuestionsScreen.routeName).then((value) => bloc.add(SaveChangesAction())),
                    ),
                    ProfileOptionWithGraphicAndAdd(
                      title: AppLocalizations.of(context)!.physical_activity,
                      widget: FillHorizontalBar(
                        fractionToFill: bloc.getPhysicalCharacteristicsFillPercentage(),
                        height: 9,
                      ),
                      onAdd: () => Navigator.pushNamed(context, PhysicalActivityScreen.routeName).then((value) => bloc.add(SaveChangesAction())),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: const CustomBottomAppBar(initStateCallback : null),
              resizeToAvoidBottomInset: true,
              floatingActionButton: FloatingActionButton(
                elevation: 2.0,
                backgroundColor: Colors.white,
                onPressed: () { Navigator.popAndPushNamed(context, DashboardScreen.routeName); },
                child: Container(
                  padding: const EdgeInsets.all(Dimens.paddingSmall),
                  child: Image.asset(
                    'assets/images/logo_black.png',
                    fit: BoxFit.cover,
                    color: Colors.black,
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,);
          },
        ),
      ),
    );
  }


}