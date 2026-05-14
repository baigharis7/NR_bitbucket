import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class ActivityLogWidget extends StatelessWidget {
  final List<SportEventComplete> sportEvents;
  final VoidCallback onAdd;
  final VoidCallback onTap;
  final bool showHealthSyncPrompt;
  final VoidCallback? onHealthSyncTap;
  final VoidCallback? onHealthSyncDismiss;
  static const int _maxItems = 3;

  const ActivityLogWidget({
    super.key,
    required this.sportEvents,
    required this.onAdd,
    required this.onTap,
    this.showHealthSyncPrompt = false,
    this.onHealthSyncTap,
    this.onHealthSyncDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEvents = [...sportEvents]..sort((a, b) {
      final aTime = (a.info?.isNotEmpty ?? false) ? a.info!.first.timeStart : null;
      final bTime = (b.info?.isNotEmpty ?? false) ? b.info!.first.timeStart : null;
      return (bTime ?? b.eventDate).compareTo(aTime ?? a.eventDate);
    });
    final recentEvents = sortedEvents.length > _maxItems
        ? sortedEvents.sublist(0, _maxItems)
        : sortedEvents;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        decoration: BoxDecoration(
          color: AppColors.floralWhite,
          borderRadius: BorderRadius.circular(Dimens.border20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row: image + title + add button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Image.asset('assets/images/sport.png', width: 48, height: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.activity_log,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: Dimens.fontSizeLarge,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onAdd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 32 * 0.85,
                          height: 32 * 0.85,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const Icon(Icons.add_circle, size: 32, color: AppColors.yellowishGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (recentEvents.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.black26, height: 12),
              ),
              // Activity items
              ...recentEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return _buildActivityItem(context, event, isLast: index == recentEvents.length - 1);
              }),
            ],
            if (recentEvents.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.black26, height: 12),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  AppLocalizations.of(context)!.no_activity_recorded,
                  style: TextStyle(
                    fontSize: Dimens.fontSizeMedium,
                    color: AppColors.yellowishGreen,
                  ),
                ),
              ),
            ],
            if (showHealthSyncPrompt) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.black26, height: 12),
              ),
              _buildHealthSyncPrompt(context),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSyncPrompt(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onHealthSyncTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.monitor_heart,
              size: 28,
              color: AppColors.yellowishGreen,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.health_sync_enable_link,
                style: TextStyle(
                  fontSize: Dimens.fontSizeMedium,
                  color: AppColors.yellowishGreen,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.yellowishGreen,
                ),
              ),
            ),
            GestureDetector(
              onTap: onHealthSyncDismiss,
              child: Icon(
                Icons.cancel_outlined,
                size: 24,
                color: AppColors.battleshipGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, SportEventComplete event, {required bool isLast}) {
    final sportName = event.displayName(context);

    // Build duration from first info or sum all
    final totalMinutes = event.info?.fold<int>(0, (sum, info) => sum + info.minutes) ?? 0;
    final kcal = event.eventKcals ?? 0;

    final isSynced = event.source != null && event.source != 'manual';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 16, top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sportName,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: Dimens.fontSizeMedium,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppLocalizations.of(context)!.duration}: $totalMinutes mins.  -  ${AppLocalizations.of(context)!.energy}: -$kcal kcal.',
                      style: TextStyle(
                        fontSize: Dimens.fontSizeSmall,
                        color: AppColors.battleshipGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSynced) ...[
                const SizedBox(width: 10),
                Icon(Icons.monitor_heart, size: 30, color: AppColors.yellowishGreen),
              ],
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.black26, height: 1),
          ),
      ],
    );
  }
}
