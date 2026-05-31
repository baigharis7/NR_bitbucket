import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';

/// Onboarding screen for health app sync, shown during registration flow.
/// Promotes syncing with HealthKit/Health Connect and allows users to
/// connect or skip.
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

        // Navigate to objectives after successful connection
        if (state.permissionGranted == true) {
          Navigator.of(context).popAndPushNamed(ObjectivesScreen.routeName);
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
                    const SizedBox(height: Dimens.height32),
                    Image.asset(
                      'assets/images/logo_name_white.png',
                      width: 200,
                      color: Colors.white,
                    ),
                    const SizedBox(height: Dimens.paddingLarge),

                    // Intro / promo card (mirrors settings toggle card)
                    _buildIntroCard(context),

                    // HC install button (Android only, when HC not available)
                    if (Platform.isAndroid && !state.isAvailable && !state.isLoading)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: Dimens.paddingLarge,
                          right: Dimens.paddingLarge,
                          top: Dimens.paddingLarge,
                        ),
                        child: GeneralButton(
                          title: AppLocalizations.of(context)!
                              .health_sync_hc_install_button,
                          onTap: () =>
                              _bloc.add(HealthSyncInstallHealthConnect()),
                        ),
                      ),

                    const SizedBox(height: Dimens.paddingLarge),

                    // Data types card (mirrors settings data-types card)
                    Expanded(
                      child: SingleChildScrollView(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
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

                    // Connect Now button (mirrors Sync Now button)
                    Container(
                      margin: const EdgeInsets.only(
                        left: Dimens.paddingLarge,
                        right: Dimens.paddingLarge,
                        top: Dimens.paddingLarge,
                      ),
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
                      onPressed: () {
                        Navigator.of(context).popAndPushNamed(
                          ObjectivesScreen.routeName,
                        );
                      },
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
                    const SizedBox(height: Dimens.paddingLarge),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingNormal,
        vertical: Dimens.paddingNormal,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellowishGreen59,
        borderRadius: BorderRadius.circular(Dimens.border15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monitor_heart,
            size: 36,
            color: Colors.white,
          ),
          const SizedBox(width: Dimens.width12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.health_sync_title,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Dimens.fontSize15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.health_sync_description,
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontSize: Dimens.fontSizeSmall,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
