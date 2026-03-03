import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/screen_top_bar.dart';
import 'package:intl/intl.dart';

/// Settings screen for health app sync configuration.
/// Allows users to enable/disable sync, manually trigger sync,
/// and view sync status.
class HealthSyncSettingsScreen extends StatefulWidget {
  static const routeName = '/health_sync_settings_screen';

  const HealthSyncSettingsScreen({super.key});

  @override
  State<HealthSyncSettingsScreen> createState() => _HealthSyncSettingsScreenState();
}

class _HealthSyncSettingsScreenState extends State<HealthSyncSettingsScreen>
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
    // Re-check availability when returning from Play Store (after installing Health Connect)
    if (state == AppLifecycleState.resumed) {
      _bloc.add(HealthSyncInitialization());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthSyncBloc, HealthSyncState>(
      listener: (context, state) {
        if (state.isLoading && !state.isSyncing) {
          LoadingScreen.instance().show(
            context: context,
            text: AppLocalizations.of(context)!.loading,
          );
        } else if (!state.isLoading) {
          LoadingScreen.instance().hide();
        }

        if (state.syncSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.yellowishGreen,
              content: Text(
                AppLocalizations.of(context)!.health_sync_success,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        // Show permission denied message (separate from errors)
        if (state.permissionGranted == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                AppLocalizations.of(context)!.health_sync_no_permission,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (state.onError != null) {
          showErrorSnackBar(
            context,
            AppLocalizations.of(context)!.health_sync_error,
          );
        }

        // Show Health Connect setup guide after enabling sync on Android
        if (state.showHcSetupGuide == true) {
          _showHcSetupBottomSheet(context);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),

            // Foreground content
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: Dimens.paddingLarge),

                    // Header
                    ScreenTopBar(
                      title: AppLocalizations.of(context)!.health_sync_section_title,
                      onBack: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: Dimens.paddingLarge),

                    // Toggle card
                    _buildToggleCard(context, state),

                    // Health Connect action button (Android only)
                    if (Platform.isAndroid && !state.isAvailable)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: Dimens.paddingLarge,
                          right: Dimens.paddingLarge,
                          top: Dimens.paddingLarge,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          onTap: () => _bloc.add(HealthSyncInstallHealthConnect()),
                          child: Container(
                            height: Dimens.height55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.yellowishGreen,
                              border: Border.all(color: AppColors.whit),
                              borderRadius: BorderRadius.circular(Dimens.border18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.health_sync_hc_install_button,
                                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize19),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.open_in_new, size: 18, color: AppColors.whit),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (Platform.isAndroid && state.isAvailable && state.isSyncEnabled)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: Dimens.paddingLarge,
                          right: Dimens.paddingLarge,
                          top: Dimens.paddingLarge,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Dimens.border18),
                          onTap: () => _bloc.add(HealthSyncOpenHealthConnect()),
                          child: Container(
                            height: Dimens.height55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.yellowishGreen,
                              border: Border.all(color: AppColors.whit),
                              borderRadius: BorderRadius.circular(Dimens.border18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.health_sync_hc_open_button,
                                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize19),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.open_in_new, size: 18, color: AppColors.whit),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: Dimens.paddingLarge),

                    // Data types card (wraps content, scrollable if needed)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.padding20,
                            vertical: Dimens.paddingLarge,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.floralWhite,
                            borderRadius: BorderRadius.circular(Dimens.border15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Last sync time
                              if (state.lastSyncTime != null) ...[
                                _buildInfoTile(
                                  context,
                                  icon: Icons.access_time,
                                  label: AppLocalizations.of(context)!.health_sync_last_sync(
                                    DateFormat('MMM d, yyyy HH:mm').format(state.lastSyncTime!),
                                  ),
                                ),
                                const SizedBox(height: Dimens.height12),
                              ],

                              // Synced activities count
                              if (state.syncedActivitiesCount != null && state.syncedActivitiesCount! > 0) ...[
                                _buildInfoTile(
                                  context,
                                  icon: Icons.check_circle_outline,
                                  label: AppLocalizations.of(context)!.health_sync_activities_imported(
                                    state.syncedActivitiesCount!,
                                  ),
                                ),
                                const SizedBox(height: Dimens.height12),
                              ],

                              // Data type items
                              _buildDataTypeItem(context, Icons.fitness_center, 'Workouts'),
                              _buildDataTypeItem(context, Icons.local_fire_department, 'Active Calories'),
                              _buildDataTypeItem(context, Icons.favorite, 'Heart Rate'),
                              _buildDataTypeItem(context, Icons.directions_walk, 'Steps'),
                              _buildDataTypeItem(context, Icons.straighten, 'Distance', showDivider: false),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Sync Now button fixed at bottom
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingLarge,
                        vertical: Dimens.marginSmall,
                      ),
                      child: GeneralButton(
                        title: state.isSyncing
                            ? AppLocalizations.of(context)!.health_sync_syncing
                            : AppLocalizations.of(context)!.health_sync_now,
                        selectedColor: state.isSyncEnabled && !state.isSyncing
                            ? AppColors.yellowishGreen
                            : AppColors.yellowishGreen.withOpacity(0.4),
                        onTap: state.isSyncEnabled && !state.isSyncing
                            ? () => _bloc.add(HealthSyncManualTrigger())
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggleCard(BuildContext context, HealthSyncState state) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // NutreNaissance logo
              Image.asset(
                'assets/images/logo_.png',
                width: 36,
                height: 36,
                color: Colors.white,
              ),
              const SizedBox(width: Dimens.width12),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.health_sync_enable_link,
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
              const SizedBox(width: Dimens.marginSmall),
              // Toggle switch — disabled if HC not available
              Switch.adaptive(
                value: state.isSyncEnabled,
                onChanged: state.isAvailable
                    ? (value) => _bloc.add(HealthSyncToggle(enable: value))
                    : null,
                activeColor: Colors.white,
                activeTrackColor: AppColors.mountainMeadow,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
          // HC not installed callout (Android only)
          if (Platform.isAndroid && !state.isAvailable) ...[
            const Divider(color: Colors.white38, height: 1),
            const SizedBox(height: Dimens.paddingNormal),
            Text(
              AppLocalizations.of(context)!.health_sync_hc_install_message,
              style: AppTextStyles.radioCanadaBig.copyWith(
                fontSize: Dimens.fontSizeNormal,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
          // HC installed + sync enabled — prompt to connect apps
          if (Platform.isAndroid && state.isAvailable && state.isSyncEnabled) ...[
            const Divider(color: Colors.white38, height: 1),
            const SizedBox(height: Dimens.paddingNormal),
            Text(
              AppLocalizations.of(context)!.health_sync_hc_connect_message,
              style: AppTextStyles.radioCanadaBig.copyWith(
                fontSize: Dimens.fontSizeNormal,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.yellowishGreen.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.radioCanadaBig.copyWith(
              fontSize: Dimens.fontSizeNormal,
              color: AppColors.yellowishGreen.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTypeItem(BuildContext context, IconData icon, String label, {bool showDivider = true}) {
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

  void _showHcSetupBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.yellowishGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync,
                    size: 32,
                    color: AppColors.yellowishGreen,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  l10n.health_sync_hc_setup_title,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: Dimens.fontSizeXLarge,
                    color: AppColors.yellowishGreen,
                  ),
                ),
                const SizedBox(height: 12),

                // Body
                Text(
                  l10n.health_sync_hc_setup_body,
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontSize: Dimens.fontSizeNormal,
                    color: AppColors.battleshipGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Steps
                _buildStep(1, l10n.health_sync_hc_setup_step1),
                _buildStep(2, l10n.health_sync_hc_setup_step2),
                _buildStep(3, l10n.health_sync_hc_setup_step3),
                const SizedBox(height: 24),

                // Open Health Connect button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _bloc.add(HealthSyncOpenHealthConnect());
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.health_sync_hc_setup_open),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellowishGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Got it button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      l10n.health_sync_hc_setup_done,
                      style: TextStyle(
                        color: AppColors.yellowishGreen.withOpacity(0.7),
                        fontSize: Dimens.fontSize15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.yellowishGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.yellowishGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
