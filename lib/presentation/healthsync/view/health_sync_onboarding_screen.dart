import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/onboarding_progress_dots.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/screen_top_bar.dart';

/// Onboarding screen for health app sync, shown during registration flow.
/// Promotes syncing with HealthKit/Health Connect and allows users to
/// connect or skip. This is the final step of the onboarding flow — on
/// Connect or Skip we persist the profile and jump to the dashboard.
class HealthSyncOnboardingScreen extends StatefulWidget {
  static const routeName = '/health_sync_onboarding_screen';

  const HealthSyncOnboardingScreen({super.key});

  @override
  State<HealthSyncOnboardingScreen> createState() =>
      _HealthSyncOnboardingScreenState();
}

class _HealthSyncOnboardingScreenState extends State<HealthSyncOnboardingScreen>
    with WidgetsBindingObserver {
  late HealthSyncBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<HealthSyncBloc>(context);
    _bloc.add(HealthSyncInitialization());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.add(HealthSyncInitialization());
    }
  }

  void _goToDashboard(BuildContext context) {
    // Profile is already persisted at the Objectives "Next" step, so this
    // screen just navigates and never needs to re-save.
    Navigator.of(context)
        .pushNamedAndRemoveUntil(DashboardScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthSyncBloc, HealthSyncState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen.instance().show(
            context: context,
            text: AppLocalizations.of(context)!.loading,
          );
        } else {
          LoadingScreen.instance().hide();
        }

        // After successful connection, finalize the profile and go to dashboard.
        if (state.permissionGranted == true) {
          _goToDashboard(context);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0)),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: Dimens.height12),
                    ScreenTopBar(
                      onBack: () => Navigator.of(context).popAndPushNamed(
                        ObjectivesScreen.routeName,
                        arguments: const {'isOnboarding': true},
                      ),
                    ),
                    const SizedBox(height: Dimens.height12),
                    Image.asset(
                      'assets/images/logo_name_white.png',
                      width: 200,
                      color: Colors.white,
                    ),
                    const SizedBox(height: Dimens.paddingLarge),

                    // HC install button (Android only, when HC not available)
                    if (Platform.isAndroid && !state.isAvailable && !state.isLoading)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: Dimens.paddingLarge,
                          right: Dimens.paddingLarge,
                          bottom: Dimens.paddingLarge,
                        ),
                        child: GeneralButton(
                          title: AppLocalizations.of(context)!
                              .health_sync_hc_install_button,
                          onTap: () =>
                              _bloc.add(HealthSyncInstallHealthConnect()),
                        ),
                      ),

                    // Main floralWhite card: title + data types
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimens.paddingLarge),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.padding20,
                          vertical: Dimens.paddingLarge,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.floralWhite,
                          borderRadius:
                              BorderRadius.circular(Dimens.border15),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                titleAlignment: ListTileTitleAlignment.top,
                                leading: const Icon(
                                  Icons.monitor_heart,
                                  size: 35,
                                  color: AppColors.yellowishGreen,
                                ),
                                horizontalTitleGap: 6,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .health_sync_onboarding_title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: Dimens.fontSizeXXLarge,
                                    color: AppColors.yellowishGreen,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .health_sync_description,
                                    style: AppTextStyles.radioCanadaBig.copyWith(
                                      fontSize: Dimens.fontSizeNormal,
                                      color: AppColors.yellowishGreen,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimens.height12),
                              _buildDataTypeItem(context,
                                  Icons.fitness_center, 'Workouts'),
                              _buildDataTypeItem(context,
                                  Icons.local_fire_department, 'Active Calories'),
                              _buildDataTypeItem(
                                  context, Icons.favorite, 'Heart Rate'),
                              _buildDataTypeItem(
                                  context, Icons.directions_walk, 'Steps'),
                              _buildDataTypeItem(
                                  context, Icons.straighten, 'Distance'),
                              _buildDataTypeItem(
                                  context, Icons.bedtime, 'Sleep',
                                  showDivider: false),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimens.height25),

                    // Connect Now button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                      child: GeneralButton(
                        title:
                            AppLocalizations.of(context)!.health_sync_connect,
                        selectedColor: state.isAvailable
                            ? AppColors.yellowishGreen
                            : AppColors.yellowishGreen.withOpacity(0.4),
                        onTap: state.isAvailable
                            ? () => _bloc.add(HealthSyncRequestPermissions())
                            : null,
                      ),
                    ),

                    // Skip for now
                    TextButton(
                      onPressed: () => _goToDashboard(context),
                      child: Text(
                        AppLocalizations.of(context)!.health_sync_skip,
                        style: AppTextStyles.radioCanadaBig.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: Dimens.fontSizeNormal,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),

                    const OnboardingProgressDots(currentStep: 3),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTypeItem(BuildContext context, IconData icon, String label,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.paddingNormal),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.yellowishGreen,
              ),
              const SizedBox(width: Dimens.width12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontSize: Dimens.fontSizeMedium,
                    fontWeight: FontWeight.w400,
                    color: AppColors.yellowishGreen,
                  ),
                ),
              ),
              const Icon(
                Icons.check,
                size: 22,
                color: AppColors.yellowishGreen,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.yellowishGreen.withOpacity(0.3),
            height: 1,
          ),
      ],
    );
  }
}
