import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:intl/intl.dart';

/// Settings screen for health app sync configuration.
/// Allows users to enable/disable sync, manually trigger sync,
/// and view sync status.
class HealthSyncSettingsScreen extends StatelessWidget {
  static const routeName = '/health_sync_settings_screen';

  const HealthSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HealthSyncBloc>(context);
    bloc.add(HealthSyncInitialization());

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: const CustomBottomNaviBarWidget(
                activePosition: Constants.PROFILE,
              ),
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
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: Dimens.height37 * fontScale,
                                      color: AppColors.yellowishGreen,
                                    ),
                                    const SizedBox(width: Dimens.width12),
                                    Text(
                                      AppLocalizations.of(context)!.health_sync_settings,
                                      style: AppTextStyles.merriWeather.copyWith(
                                        fontSize: 20 * fontScale,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    size: Dimens.height30 * fontScale,
                                    color: AppColors.yellowishGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimens.height12),
                            const Divider(
                              color: AppColors.yellowishGreen,
                              thickness: 1,
                            ),
                            SizedBox(height: height * 0.03),

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
                                    // Install Health Connect button (Android only)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          bloc.add(HealthSyncInstallHealthConnect());
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
                                bloc.add(HealthSyncToggle(enable: value));
                              },
                            ),
                            SizedBox(height: height * 0.02),

                            // Last sync time
                            if (state.lastSyncTime != null)
                              _buildInfoTile(
                                context,
                                icon: Icons.access_time,
                                label: AppLocalizations.of(context)!.health_sync_last_sync(
                                  DateFormat('MMM d, yyyy HH:mm').format(state.lastSyncTime!),
                                ),
                              ),
                            SizedBox(height: height * 0.02),

                            // Synced activities count
                            if (state.syncedActivitiesCount != null && state.syncedActivitiesCount! > 0)
                              _buildInfoTile(
                                context,
                                icon: Icons.check_circle_outline,
                                label: AppLocalizations.of(context)!.health_sync_activities_imported(
                                  state.syncedActivitiesCount!,
                                ),
                              ),
                            SizedBox(height: height * 0.03),

                            // Sync Now button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: state.isSyncEnabled && !state.isSyncing
                                    ? () {
                                        bloc.add(HealthSyncManualTrigger());
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
                            SizedBox(height: height * 0.03),

                            // Data types section
                            Text(
                              'Synced Data Types',
                              style: AppTextStyles.merriWeather.copyWith(
                                fontSize: Dimens.fontSize19 * fontScale,
                                color: AppColors.yellowishGreen,
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
                      );
                    },
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
        vertical: Dimens.padding10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.merriWeather.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: Dimens.fontSize15,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.yellowishGreen,
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
          color: AppColors.battleshipGrey,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.radioCanadaBig.copyWith(
            fontSize: Dimens.fontSize15,
            color: AppColors.battleshipGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTypeItem(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.yellowishGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.yellowishGreen,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.radioCanadaBig.copyWith(
              fontSize: Dimens.fontSize15,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check,
            size: 18,
            color: AppColors.yellowishGreen,
          ),
        ],
      ),
    );
  }
}
