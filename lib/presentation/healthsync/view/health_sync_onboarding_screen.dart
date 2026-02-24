import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

/// Onboarding screen for health app sync, shown during registration flow.
/// Promotes syncing with HealthKit/Health Connect and allows users to
/// connect or skip.
class HealthSyncOnboardingScreen extends StatefulWidget {
  static const routeName = '/health_sync_onboarding_screen';

  const HealthSyncOnboardingScreen({super.key});

  @override
  State<HealthSyncOnboardingScreen> createState() => _HealthSyncOnboardingScreenState();
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
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.floralWhite,
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimens.marginXXXLarge,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Health sync icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.yellowishGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.watch,
                          size: 50,
                          color: AppColors.yellowishGreen,
                        ),
                      ),
                      const SizedBox(height: Dimens.height25),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.health_sync_title,
                        style: AppTextStyles.merriWeather.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Dimens.fontSizeXLarge,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Dimens.height12),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.padding10,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.health_sync_description,
                          style: AppTextStyles.radioCanadaBig.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: Dimens.fontSizeNormal,
                            color: AppColors.battleshipGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Dimens.height37),

                      // Data types we'll sync
                      _buildDataTypesList(context),
                      const SizedBox(height: Dimens.height37),

                      // Not available message with Install button
                      if (!state.isAvailable && !state.isLoading)
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.health_sync_not_available,
                              style: AppTextStyles.radioCanadaBig.copyWith(
                                fontSize: Dimens.fontSizeSmall,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Dimens.height12),
                            OutlinedButton.icon(
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
                            const SizedBox(height: Dimens.height12),
                          ],
                        ),

                      // Connect Now button
                      RoundedCustomButton(
                        onPressed: () {
                          _bloc.add(HealthSyncRequestPermissions());
                        },
                        enableButton: state.isAvailable,
                        buttonText: AppLocalizations.of(context)!.health_sync_connect,
                      ),
                      const SizedBox(height: Dimens.height12),

                      // Skip for now link
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
                            color: AppColors.yellowishGreen,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTypesList(BuildContext context) {
    final dataTypes = [
      {'icon': Icons.fitness_center, 'label': 'Workouts'},
      {'icon': Icons.directions_walk, 'label': 'Steps'},
      {'icon': Icons.local_fire_department, 'label': 'Calories'},
      {'icon': Icons.favorite, 'label': 'Heart Rate'},
      {'icon': Icons.straighten, 'label': 'Distance'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: dataTypes.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.yellowishGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type['icon'] as IconData,
                size: 16,
                color: AppColors.yellowishGreen,
              ),
              const SizedBox(width: 4),
              Text(
                type['label'] as String,
                style: AppTextStyles.radioCanadaBig.copyWith(
                  fontSize: Dimens.fontSizeSmall,
                  color: AppColors.yellowishGreen,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
