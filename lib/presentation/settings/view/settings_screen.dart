import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/privacy/view/policy_screen.dart';
import 'package:nutrenaissance_flutter/presentation/settings/bloc/settings_bloc.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../common/view/loading_screen.dart';
import '../../login/view/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings_screen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final ScrollController _scrollController = ScrollController();


    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocProvider.value(
        value: settingsBloc,
      child: BlocConsumer<SettingsBloc, SettingsState>(
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

          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Container(
                width: width,
                height: height,
                decoration: const BoxDecoration(
                  color: AppColors.floralWhite,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double fontScale = constraints.maxWidth * 0.0025;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.02,
                        horizontal: width * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings, size: Dimens.height37 * fontScale, color: AppColors.yellowishGreen),
                                  const SizedBox(width: Dimens.width12),
                                  Text(
                                    AppLocalizations.of(context)!.settings,
                                    style: AppTextStyles.merriWeather.copyWith(fontSize: 20 * fontScale, color: Colors.black,),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close, size: Dimens.height30 * fontScale, color: AppColors.yellowishGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimens.height12),
                          const Divider(color: AppColors.yellowishGreen, thickness: 1,),
                          SizedBox(height: height * 0.03),
                          _menuTile(AppLocalizations.of(context)!.log_out, onTap: () => settingsBloc.add(SettingsLogOut(goToLogin: () => Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false,))),),
                          SizedBox(height: height * 0.03),
                          Text(AppLocalizations.of(context)!.feedback_support,
                            style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize19 * fontScale, color: AppColors.yellowishGreen),
                          ),
                          const SizedBox(height: Dimens.height12),
                          _menuTile(AppLocalizations.of(context)!.whatsapp_contact),
                          _menuTile(AppLocalizations.of(context)!.feedback_form),
                          SizedBox(height: height * 0.03),
                          Text(AppLocalizations.of(context)!.legal_text,
                            style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize19 * fontScale, color: AppColors.yellowishGreen),
                          ),
                          const SizedBox(height: Dimens.height12),
                          _menuTile(AppLocalizations.of(context)!.legal_advise),
                          _menuTile(AppLocalizations.of(context)!.privacy_polic, onTap: () => Navigator.pushNamed(context, PolicyScreen.routeName),),
                          _menuTile(AppLocalizations.of(context)!.cookies_policy),
                          SizedBox(height: height * 0.08),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/logo_name_white.png',
                                      width: 200,
                                      color: AppColors.yellowishGreen,
                                    ),
                                    // const Spacer(),
                                    // Text(
                                    //   "NutreNaissance",
                                    //   style: TextStyle(
                                    //     fontSize: 14 * fontScale,
                                    //     fontWeight: FontWeight.w500,
                                    //     color: Colors.black87,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: Dimens.height25),
                                Text(
                                  AppLocalizations.of(context)!.all_rights_reserved,
                                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize15 * fontScale, color: AppColors.yellowishGreen),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],);
      },),
    );
  }

  /// Reusable menu tile widget
  Widget _menuTile(String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          onTap: () => onTap?.call(),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding10),
          title: Text(
            title,
            style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize15, color: AppColors.yellowishGreen),
          ),
          trailing:  const Icon(Icons.chevron_right, size: 20, color: AppColors.yellowishGreen,),
        ),
        const Divider(color: AppColors.yellowishGreen, height: 0.5,),
      ],
    );
  }
}
