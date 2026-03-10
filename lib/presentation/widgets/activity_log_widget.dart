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
  static const int _maxItems = 3;

  const ActivityLogWidget({
    super.key,
    required this.sportEvents,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recentEvents = sportEvents.length > _maxItems
        ? sportEvents.sublist(0, _maxItems)
        : sportEvents;

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
                    child: const Icon(Icons.add_circle, size: 32, color: AppColors.yellowishGreen),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, SportEventComplete event, {required bool isLast}) {
    // Get sport name from first info item
    final sportName = event.sportName ??
        (event.info != null && event.info!.isNotEmpty
            ? event.info![0].translate(context)
            : '');

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
