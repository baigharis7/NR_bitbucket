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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimens.height32),
                      // Logo
                      Image.asset(
                        'assets/images/logo_name_white.png',
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: Dimens.height32),
                      // Main content container
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(Dimens.padding4),
                          decoration: BoxDecoration(
                            color: AppColors.floralWhite,
                            borderRadius: BorderRadius.circular(Dimens.border11),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimens.padding20,
                              vertical: Dimens.padding4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                ListTile(
                                  titleAlignment: ListTileTitleAlignment.top,
                                  leading: const Icon(
                                    Icons.sync,
                                    size: 35,
                                    color: AppColors.peacockBlue,
                                  ),
                                  horizontalTitleGap: Dimens.zero,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    AppLocalizations.of(context)!.health_sync_settings,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: Dimens.fontSizeXXLarge,
                                      color: AppColors.peacockBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimens.height12),

                                // Availability status with Install Health Connect button
                                if (!state.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.all(Dimens.padding10),
                                    margin: const EdgeInsets.only(bottom: Dimens.height12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.warning_amber,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                AppLocalizations.of(context)!.health_sync_not_available,
                                                style: AppTextStyles.radioCanadaBig.copyWith(
                                                  fontSize: Dimens.fontSize15,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              _bloc.add(HealthSyncInstallHealthConnect());
                                            },
                                            icon: const Icon(Icons.download, size: 18),
                                            label: const Text('Install Health Connect'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.orange,
                                              side: const BorderSide(color: Colors.orange),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Enable/Disable toggle
                                _buildToggleTile(
                                  context,
                                  title: AppLocalizations.of(context)!.health_sync_enable,
                                  value: state.isSyncEnabled,
                                  enabled: state.isAvailable,
                                  onChanged: (value) {
                                    _bloc.add(HealthSyncToggle(enable: value));
                                  },
                                ),
                                const SizedBox(height: Dimens.height12),

                                // Last sync time
                                if (state.lastSyncTime != null)
                                  _buildInfoTile(
                                    context,
                                    icon: Icons.access_time,
                                    label: AppLocalizations.of(context)!.health_sync_last_sync(
                                      DateFormat('MMM d, yyyy HH:mm').format(state.lastSyncTime!),
                                    ),
                                  ),
                                const SizedBox(height: Dimens.height12),

                                // Synced activities count
                                if (state.syncedActivitiesCount != null && state.syncedActivitiesCount! > 0)
                                  _buildInfoTile(
                                    context,
                                    icon: Icons.check_circle_outline,
                                    label: AppLocalizations.of(context)!.health_sync_activities_imported(
                                      state.syncedActivitiesCount!,
                                    ),
                                  ),
                                const SizedBox(height: Dimens.height32),

                                // Data types section
                                Text(
                                  AppLocalizations.of(context)!.health_sync_data_types,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: Dimens.fontSizeLarge,
                                    color: AppColors.peacockBlue,
                                  ),
                                ),
                                const SizedBox(height: Dimens.height12),
                                _buildDataTypeItem(context, Icons.fitness_center, 'Workouts'),
                                _buildDataTypeItem(context, Icons.directions_walk, 'Steps'),
                                _buildDataTypeItem(context, Icons.local_fire_department, 'Active Calories'),
                                _buildDataTypeItem(context, Icons.favorite, 'Heart Rate'),
                                _buildDataTypeItem(context, Icons.straighten, 'Distance'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.height32),
                      // Sync Now button at bottom
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isSyncEnabled && !state.isSyncing
                              ? () {
                                  _bloc.add(HealthSyncManualTrigger());
                                }
                              : null,
                          icon: state.isSyncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.sync),
                          label: Text(
                            state.isSyncing
                                ? AppLocalizations.of(context)!.health_sync_syncing
                                : AppLocalizations.of(context)!.health_sync_now,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellowishGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimens.padding10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.height32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.padding10,
        vertical: Dimens.padding4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.peacockBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Dimens.fontSize15,
                color: enabled ? AppColors.peacockBlue : Colors.grey,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.peacockBlue,
          ),
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
          color: AppColors.peacockBlue.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Dimens.fontSizeNormal,
              color: AppColors.peacockBlue.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTypeItem(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.peacockBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.peacockBlue,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: Dimens.fontSize15,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.check,
            size: 18,
            color: AppColors.peacockBlue.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
