import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:flutter_svg/svg.dart';

class CalendarPaneScreen extends StatefulWidget {
  static const routeName = '/calendar_pane_screen';

  final DateTime initialDate;
  final DashboardAllCalendarEvents? allCalendarEvents;
  final Function(DateTime) onDateSelected;
  final EventsHelper eventsHelper;
  final int? totalKcal;
  final double? totalWater;
  final Set<int>? programmedWeekdays;
  final List<FoodRoutineEvent>? mealRoutines;
  final List<SportRoutineCompleted>? sportRoutines;
  final List<SupplementSimple>? supplementRoutines;

  const CalendarPaneScreen({
    super.key,
    required this.initialDate,
    this.allCalendarEvents,
    required this.onDateSelected,
    required this.eventsHelper,
    this.totalKcal,
    this.totalWater,
    this.programmedWeekdays,
    this.mealRoutines,
    this.sportRoutines,
    this.supplementRoutines,
  });

  @override
  State<CalendarPaneScreen> createState() => _CalendarPaneScreenState();
}

class _CalendarPaneScreenState extends State<CalendarPaneScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedMonth;
  final GlobalKey _monthKey = GlobalKey();
  final GlobalKey _yearKey = GlobalKey();
  final ScrollController _diaryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate;
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  void dispose() {
    _diaryScrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  /// Returns food, sport, and supplement events for the given day.
  List<dynamic> _getRoutineEventsForDay(DateTime date) {
    if (widget.allCalendarEvents == null) return [];
    final allEvents = widget.eventsHelper.foundEventsFromGivenDate(
        widget.allCalendarEvents!, date);
    final routineEvents = allEvents
        .where((e) => e is FoodEventComplete || e is SportEventComplete)
        .toList();
    // Supplement events aren't in foundEventsFromGivenDate, filter separately
    final supplementEvents = widget.allCalendarEvents!.supplementEvents ?? [];
    for (final s in supplementEvents) {
      if (s.eventDate != null && _isSameDay(date,
          DateTime.fromMillisecondsSinceEpoch(s.eventDate!))) {
        routineEvents.add(s);
      }
    }
    return routineEvents;
  }

  /// Returns whether any events at all exist for the given day (for calendar dots).
  bool _hasAnyEventsForDay(DateTime date) {
    if (widget.allCalendarEvents == null) return false;
    return widget.eventsHelper
        .foundEventsFromGivenDate(widget.allCalendarEvents!, date)
        .isNotEmpty;
  }

  /// Returns whether a routine is programmed for the given day's weekday.
  bool _hasRoutineProgrammedForDay(DateTime date) {
    if (widget.programmedWeekdays == null ||
        widget.programmedWeekdays!.isEmpty) return false;
    return widget.programmedWeekdays!.contains(date.weekday);
  }

  /// Returns programmed routine items for a given day (matched by weekday).
  List<_ProgrammedRoutineItem> _getProgrammedRoutinesForDay(DateTime date) {
    final weekday = date.weekday;
    final items = <_ProgrammedRoutineItem>[];

    for (final r in widget.mealRoutines ?? <FoodRoutineEvent>[]) {
      if (r.daysOfWeek?.contains(weekday) == true) {
        items.add(_ProgrammedRoutineItem(
          title: r.foodName ?? '',
          type: _RoutineType.food,
          time: r.time,
          mealType: r.mealType ?? 0,
        ));
      }
    }
    for (final r in widget.sportRoutines ?? <SportRoutineCompleted>[]) {
      if (r.daysOfWeek?.contains(weekday) == true) {
        items.add(_ProgrammedRoutineItem(
          title: r.sportName ?? '',
          type: _RoutineType.sport,
          time: r.scheduleTime,
        ));
      }
    }
    for (final r in widget.supplementRoutines ?? <SupplementSimple>[]) {
      if (r.daysOfWeek?.contains(weekday) == true) {
        items.add(_ProgrammedRoutineItem(
          title: r.name ?? '',
          type: _RoutineType.supplement,
          time: r.scheduleTime,
        ));
      }
    }
    return items;
  }

  /// Returns programmed routines that don't have a matching logged event.
  List<_ProgrammedRoutineItem> _getUnloggedProgrammedRoutines(
      DateTime date, List<dynamic> loggedEvents) {
    final allProgrammed = _getProgrammedRoutinesForDay(date);
    if (loggedEvents.isEmpty) return allProgrammed;

    // Count logged food (by name+mealType), sport (by name), supplement (by name)
    final loggedFoods = <String, int>{};
    final loggedSports = <String, int>{};
    final loggedSupplements = <String, int>{};
    for (final e in loggedEvents) {
      if (e is FoodEventComplete) {
        final key =
            '${(e.foodName ?? '').toLowerCase()}|${e.mealType ?? 0}';
        loggedFoods[key] = (loggedFoods[key] ?? 0) + 1;
      } else if (e is SportEventComplete) {
        final key = (e.sportName ?? '').toLowerCase();
        loggedSports[key] = (loggedSports[key] ?? 0) + 1;
      } else if (e is SupplementSimple) {
        final key = (e.name ?? '').toLowerCase();
        loggedSupplements[key] = (loggedSupplements[key] ?? 0) + 1;
      }
    }

    return allProgrammed.where((p) {
      if (p.type == _RoutineType.food) {
        final key = '${p.title.toLowerCase()}|${p.mealType}';
        final count = loggedFoods[key] ?? 0;
        if (count > 0) {
          loggedFoods[key] = count - 1;
          return false; // matched to a logged event
        }
        return true;
      } else if (p.type == _RoutineType.sport) {
        final key = p.title.toLowerCase();
        final count = loggedSports[key] ?? 0;
        if (count > 0) {
          loggedSports[key] = count - 1;
          return false;
        }
        return true;
      } else if (p.type == _RoutineType.supplement) {
        final key = p.title.toLowerCase();
        final count = loggedSupplements[key] ?? 0;
        if (count > 0) {
          loggedSupplements[key] = count - 1;
          return false;
        }
        return true;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const CustomBottomNaviBarWidget(
        activePosition: Constants.DASHBOARD,
      ),
      body: Stack(
        children: [
          // Blurred background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: AppColors.white75Percent),
            ),
          ),
          SafeArea(
            child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset('assets/svg/calendar.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                          AppColors.calendarGreen, BlendMode.srcIn)),
                  const SizedBox(width: 10),
                  Text(
                    l10n.calendar,
                    style: AppTextStyles.merriWeather.copyWith(
                      fontSize: 20,
                      color: AppColors.calendarGreen,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        size: 28, color: AppColors.calendarGreen),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                  color: AppColors.calendarGreen, thickness: 0.5),
            ),

            // ── Today button (left) + Month / Year selectors (right) ──
            const SizedBox(height: 8),
            _buildMonthYearHeader(l10n, currentLanguage),
            const SizedBox(height: 6),

            // ── Day-of-week headers ──
            _buildDayOfWeekHeaders(currentLanguage),
            const SizedBox(height: 6),

            // ── Calendar grid ──
            _buildCalendarGrid(),
            const SizedBox(height: 10),

            // ── Legend (centered, bigger) ──
            _buildLegend(l10n),
            const SizedBox(height: 6),

            // ── Divider ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                  color: AppColors.calendarGreen, thickness: 0.5),
            ),

            // ── Routine diary (only scrollable part) ──
            Expanded(
              child: _buildRoutineDiary(l10n, currentLanguage),
            ),

            // ── Summary (fixed at bottom) ──
            _buildSummary(l10n),
          ],
        ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Month / Year header with inline popup menus
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMonthYearHeader(AppLocalizations l10n, String locale) {
    final monthName = DateFormat('MMMM', locale).format(_focusedMonth);
    final year = _focusedMonth.year.toString();
    final today = DateTime.now();
    final isAlreadyToday = _isSameDay(_selectedDay, today) &&
        _focusedMonth.year == today.year &&
        _focusedMonth.month == today.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Today button (left)
          GestureDetector(
            onTap: isAlreadyToday
                ? null
                : () {
                    widget.onDateSelected(today);
                    setState(() {
                      _selectedDay = today;
                      _focusedMonth = DateTime(today.year, today.month);
                      if (_diaryScrollController.hasClients) {
                        _diaryScrollController.jumpTo(0);
                      }
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isAlreadyToday
                    ? AppColors.calendarGreen.withValues(alpha: 0.15)
                    : AppColors.calendarGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.today,
                style: AppTextStyles.radioCanadaBig.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isAlreadyToday ? AppColors.calendarGreen : Colors.white,
                ),
              ),
            ),
          ),
          // Month + Year (right)
          Row(
            children: [
              GestureDetector(
                key: _monthKey,
                onTap: () => _showMonthPopup(locale),
                child: Row(
                  children: [
                    Text(
                      '${monthName[0].toUpperCase()}${monthName.substring(1)}',
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 17,
                        color: AppColors.calendarGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.calendarGreen, size: 22),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                key: _yearKey,
                onTap: () => _showYearPopup(),
                child: Row(
                  children: [
                    Text(
                      year,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 17,
                        color: AppColors.calendarGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.calendarGreen, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Day-of-week headers
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildDayOfWeekHeaders(String locale) {
    final firstDayOfWeek =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    DateTime monday =
        firstDayOfWeek.subtract(Duration(days: firstDayOfWeek.weekday - 1));
    final dayNames = List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return DateFormat('EEE', locale).format(date).toUpperCase();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayNames
            .map((name) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      name,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: 14,
                        color: AppColors.calendarDayGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Calendar grid
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCalendarGrid() {
    final firstOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    int leadingEmpty = firstOfMonth.weekday - 1;
    final totalDays = lastOfMonth.day;
    final totalCells = leadingEmpty + totalDays;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                if (index < leadingEmpty ||
                    index >= leadingEmpty + totalDays) {
                  if (index < leadingEmpty) {
                    // Previous month overflow
                    final prevMonthLast = DateTime(
                        _focusedMonth.year, _focusedMonth.month, 0);
                    final prevDay =
                        prevMonthLast.day - (leadingEmpty - index - 1);
                    final prevDate = DateTime(prevMonthLast.year,
                        prevMonthLast.month, prevDay);
                    return _buildDayCell(prevDate, isOutside: true);
                  }
                  final nextDay = index - leadingEmpty - totalDays + 1;
                  final nextMonth = DateTime(
                      _focusedMonth.year, _focusedMonth.month + 1, nextDay);
                  return _buildDayCell(nextMonth, isOutside: true);
                }
                final day = index - leadingEmpty + 1;
                final date = DateTime(
                    _focusedMonth.year, _focusedMonth.month, day);
                return _buildDayCell(date);
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, {bool isOutside = false}) {
    final isSelected = _isSameDay(date, _selectedDay);
    final today = _isToday(date);
    final hasEvents = _hasAnyEventsForDay(date);
    final isPast = date.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    Color? bgColor;
    Color textColor;
    if (isOutside) {
      bgColor = null;
      textColor = AppColors.calendarDayGrey.withValues(alpha: 0.4);
    } else if (isSelected) {
      bgColor = Colors.white;
      textColor = AppColors.calendarGreen;
    } else if (today) {
      bgColor = AppColors.calendarGreen;
      textColor = Colors.white;
    } else if (isPast && hasEvents) {
      bgColor = AppColors.calendarGreen72;
      textColor = Colors.white;
    } else {
      bgColor = null;
      textColor = AppColors.calendarDayGrey;
    }

    // Dot logic:
    // - Red dot: past day with no data recorded
    // - Grey dot: today or future day that has routines/activities programmed
    final hasRoutine = _hasRoutineProgrammedForDay(date);
    Color? dotColor;
    if (!isOutside) {
      if (isPast && !hasEvents) {
        dotColor = AppColors.calendarRedDot;
      } else if (!isPast && (hasEvents || hasRoutine)) {
        // today or future with programmed activities or routines
        dotColor = AppColors.calendarGreyDot;
      }
    }

    return GestureDetector(
      onTap: () {
        widget.onDateSelected(date);
        setState(() {
          _selectedDay = date;
          if (isOutside) {
            _focusedMonth = DateTime(date.year, date.month);
          }
          if (_diaryScrollController.hasClients) {
            _diaryScrollController.jumpTo(0);
          }
        });
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: isOutside
                    ? null
                    : Border.all(
                        color: AppColors.calendarGreen,
                        width: 1,
                      ),
              ),
            ),
            Text(
              date.day.toString().padLeft(2, '0'),
              style: AppTextStyles.radioCanadaBig.copyWith(
                fontSize: 14,
                color: textColor,
                fontWeight: today ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (dotColor != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Legend – centered, bigger
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildLegend(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.calendarRedDot),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.empty_record,
          style: AppTextStyles.radioCanadaBig.copyWith(
            fontSize: 13,
            color: AppColors.calendarDayGrey,
          ),
        ),
        const SizedBox(width: 28),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.calendarGreyDot),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.activities_programmed,
          style: AppTextStyles.radioCanadaBig.copyWith(
            fontSize: 13,
            color: AppColors.calendarDayGrey,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Routine diary – only this section scrolls
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildRoutineDiary(AppLocalizations l10n, String locale) {
    final routineEvents = _getRoutineEventsForDay(_selectedDay);
    // Sort ascending by event date (earliest first)
    routineEvents.sort((a, b) {
      final aDate = a is FoodEventComplete
          ? (a.eventDate ?? 0)
          : a is SportEventComplete
              ? a.eventDate
              : a is SupplementSimple
                  ? (a.eventDate ?? 0)
                  : 0;
      final bDate = b is FoodEventComplete
          ? (b.eventDate ?? 0)
          : b is SportEventComplete
              ? b.eventDate
              : b is SupplementSimple
                  ? (b.eventDate ?? 0)
                  : 0;
      return aDate.compareTo(bDate);
    });

    // Show programmed routines that don't yet have a matching logged event
    final programmedRoutines =
        _getUnloggedProgrammedRoutines(_selectedDay, routineEvents);

    // Build a unified list of diary entries (logged + programmed), sorted by time
    final diaryEntries = <_DiaryEntry>[];
    for (final e in routineEvents) {
      final millis = e is FoodEventComplete
          ? (e.eventDate ?? 0)
          : e is SportEventComplete
              ? e.eventDate
              : e is SupplementSimple
                  ? (e.eventDate ?? 0)
                  : 0;
      diaryEntries.add(_DiaryEntry(logged: e, sortMinutes: _millisToMinutes(millis)));
    }
    for (final p in programmedRoutines) {
      diaryEntries.add(_DiaryEntry(programmed: p, sortMinutes: _timeStrToMinutes(p.time)));
    }
    diaryEntries.sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));

    final hasContent = diaryEntries.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.activity_diary,
                style: AppTextStyles.merriWeather.copyWith(
                  fontSize: 17,
                  color: AppColors.calendarGreen,
                ),
              ),
              Text(
                DateFormat('EEE, MMM d', locale).format(_selectedDay),
                style: AppTextStyles.radioCanadaBig.copyWith(
                  fontSize: 14,
                  color: AppColors.calendarDayGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: AppColors.calendarGreen, thickness: 0.5),
          Expanded(
            child: !hasContent
                ? Center(
                    child: Text(
                      l10n.no_routines_scheduled,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: 14,
                        color: AppColors.calendarDayGrey,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _diaryScrollController,
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(2),
                    child: ListView.builder(
                      controller: _diaryScrollController,
                      padding: EdgeInsets.zero,
                      itemCount: diaryEntries.length,
                      itemBuilder: (ctx, i) {
                        final entry = diaryEntries[i];
                        if (entry.logged != null) {
                          return _buildRoutineItem(entry.logged!, l10n);
                        }
                        return _buildProgrammedRoutineItem(
                            entry.programmed!, l10n);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  int _millisToMinutes(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return dt.hour * 60 + dt.minute;
  }

  int _timeStrToMinutes(String? time) {
    if (time == null || time.isEmpty) return 9999;
    final parts = time.split(':');
    if (parts.length < 2) return 9999;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  Widget _buildRoutineItem(dynamic event, AppLocalizations l10n) {
    String title = '';
    String subtitle = '';

    bool isFoodEvent = false;
    bool isSupplementEvent = false;
    int mealType = 0;

    if (event is FoodEventComplete) {
      isFoodEvent = true;
      title = event.foodName ?? '';
      mealType = event.mealType ?? 0;
      subtitle =
          '${l10n.routine_label} - ${_formatEventTime(event.eventDate)}';
    } else if (event is SportEventComplete) {
      title = event.displayName(context);
      subtitle = 'WORKOUT - ${_formatEventTime(event.eventDate)}';
    } else if (event is SupplementSimple) {
      isSupplementEvent = true;
      title = event.name ?? '';
      subtitle = 'SUPPLEMENT - ${_formatEventTime(event.eventDate)}';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: isFoodEvent
                    ? Image.asset(
                        'assets/images/meal_time_$mealType.png',
                        width: 40,
                        height: 40,
                      )
                    : isSupplementEvent
                        ? Image.asset(
                            'assets/images/supplement.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/images/sport.png',
                            width: 40,
                            height: 40,
                          ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 16,
                        color: AppColors.calendarGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: AppTextStyles.radioCanadaBig.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.calendarDayGrey,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    const Icon(Icons.check,
                        size: 20, color: AppColors.calendarGreen),
                    Text(
                      l10n.logged,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.calendarGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
            color: AppColors.calendarGreen, thickness: 0.3, height: 1),
      ],
    );
  }

  Widget _buildProgrammedRoutineItem(_ProgrammedRoutineItem item, AppLocalizations l10n) {
    final isFood = item.type == _RoutineType.food;
    final isSupplement = item.type == _RoutineType.supplement;
    final timeStr = item.time ?? '';

    String subtitle;
    if (isFood) {
      subtitle = '${l10n.routine_label} ${timeStr.isNotEmpty ? '- $timeStr' : ''}';
    } else if (isSupplement) {
      subtitle = 'SUPPLEMENT ${timeStr.isNotEmpty ? '- $timeStr' : ''}';
    } else {
      subtitle = 'WORKOUT ${timeStr.isNotEmpty ? '- $timeStr' : ''}';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: isFood
                    ? Image.asset(
                        'assets/images/meal_time_${item.mealType}.png',
                        width: 40,
                        height: 40,
                      )
                    : isSupplement
                        ? Image.asset(
                            'assets/images/supplement.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/images/sport.png',
                            width: 40,
                            height: 40,
                          ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 16,
                        color: AppColors.calendarGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: AppTextStyles.radioCanadaBig.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.calendarDayGrey,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    const Icon(Icons.history,
                        size: 20, color: AppColors.calendarDayGrey),
                    Text(
                      l10n.programmed,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.calendarDayGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
            color: AppColors.calendarGreen, thickness: 0.3, height: 1),
      ],
    );
  }

  String _formatEventTime(int? millis) {
    if (millis == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Summary – fixed at bottom
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSummary(AppLocalizations l10n) {
    final consumed = widget.eventsHelper.getConsumedKcalForDay(widget.allCalendarEvents, _selectedDay);
    final remaining = (widget.totalKcal ?? 0) - consumed;
    final burned = widget.eventsHelper.getBurnedKcalForDay(widget.allCalendarEvents, _selectedDay);
    final hydrationPercent = (widget.eventsHelper.getWaterFractionForDay(widget.allCalendarEvents, _selectedDay, widget.totalWater) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
              color: AppColors.calendarGreen, thickness: 0.5),
        ),
        Container(
          color: Colors.white.withValues(alpha: 0.50),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 37),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.summary,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontSize: 17,
                    color: AppColors.calendarGreen,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      Icons.restaurant,
                      remaining.toString(),
                      l10n.remaining_kcal,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      Icons.local_fire_department,
                      burned.toString(),
                      l10n.burned_kcal,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      Icons.water_drop,
                      '$hydrationPercent%',
                      l10n.hydration.toUpperCase(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: AppColors.calendarGreen),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.calendarGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.radioCanadaBig.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.calendarGreen,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Popup pickers – appear where the dropdown is, not at the bottom
  // ──────────────────────────────────────────────────────────────────────────

  void _showMonthPopup(String locale) {
    showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Month picker',
      barrierColor: Colors.black26,
      pageBuilder: (ctx, _, __) {
        return SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.45),
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _focusedMonth.year.toString(),
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 18,
                        color: AppColors.calendarGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      childAspectRatio: 1.3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final monthDate = DateTime(_focusedMonth.year, m);
                        final name =
                            DateFormat('MMM', locale).format(monthDate);
                        final label =
                            '${name[0].toUpperCase()}${name.substring(1)}';
                        final isSelected = m == _focusedMonth.month;
                        return GestureDetector(
                          onTap: () => Navigator.pop(ctx, m),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.calendarGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.calendarGreen
                                    : AppColors.calendarDayGrey.withValues(
                                        alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: AppTextStyles.radioCanadaBig.copyWith(
                                fontSize: 15,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.calendarDayGrey,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _focusedMonth = DateTime(_focusedMonth.year, selected);
        });
      }
    });
  }

  void _showYearPopup() {
    showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Year picker',
      barrierColor: Colors.black26,
      pageBuilder: (ctx, _, __) => _YearPickerOverlay(
        selectedYear: _focusedMonth.year,
      ),
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _focusedMonth = DateTime(selected, _focusedMonth.month);
        });
      }
    });
  }
}

/// Year picker overlay with a 4x3 grid and back/forward navigation arrows.
class _YearPickerOverlay extends StatefulWidget {
  final int selectedYear;

  const _YearPickerOverlay({required this.selectedYear});

  @override
  State<_YearPickerOverlay> createState() => _YearPickerOverlayState();
}

class _YearPickerOverlayState extends State<_YearPickerOverlay> {
  static const int _yearsPerPage = 12;
  late int _rangeStart;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.selectedYear - (widget.selectedYear % _yearsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(_yearsPerPage, (i) => _rangeStart + i);

    return SafeArea(
      child: Align(
        alignment: const Alignment(0, -0.45),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Range header with navigation arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.calendarGreen, size: 28),
                      onPressed: () {
                        setState(() {
                          _rangeStart -= _yearsPerPage;
                        });
                      },
                    ),
                    Text(
                      '${years.first} – ${years.last}',
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: 18,
                        color: AppColors.calendarGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: AppColors.calendarGreen, size: 28),
                      onPressed: () {
                        setState(() {
                          _rangeStart += _yearsPerPage;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: years.map((y) {
                    final isSelected = y == widget.selectedYear;
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, y),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.calendarGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.calendarGreen
                                : AppColors.calendarDayGrey.withValues(
                                    alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          y.toString(),
                          style: AppTextStyles.radioCanadaBig.copyWith(
                            fontSize: 15,
                            color: isSelected
                                ? Colors.white
                                : AppColors.calendarDayGrey,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RoutineType { food, sport, supplement }

class _ProgrammedRoutineItem {
  final String title;
  final _RoutineType type;
  final String? time;
  final int mealType;

  const _ProgrammedRoutineItem({
    required this.title,
    required this.type,
    this.time,
    this.mealType = 0,
  });
}

class _DiaryEntry {
  final dynamic logged;
  final _ProgrammedRoutineItem? programmed;
  final int sortMinutes;

  const _DiaryEntry({this.logged, this.programmed, required this.sortMinutes});
}
