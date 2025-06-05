import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class ItemRoutineWidget extends StatefulWidget {
  final Function(TimeOfDay) onTimeChange;
  const ItemRoutineWidget({super.key, required this.onTimeChange});

  @override
  State<ItemRoutineWidget> createState() => _ItemRoutineWidgetState();
}

class _ItemRoutineWidgetState extends State<ItemRoutineWidget> {
  TimeOfDay selectedTime = TimeOfDay(hour: 0, minute: 0);

  List<String> dayAbbreviations = [];
  List<bool> selectedDays = List.generate(7, (_) => false);

  @override
  void initState() {
    _generateWeekdayAbbreviations();
    super.initState();
  }

  void _generateWeekdayAbbreviations() {
    // final currentLanguage = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final DateFormat formatter = DateFormat.E('en'); // Spanish short weekday names
    // final weekDates = DateTimeHelper.getCurrentWeekDates();;
    dayAbbreviations = List.generate(7, (i) {
      final day = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: i));
      return formatter.format(day).substring(0, 2); // e.g., "Lu", "Ma"
    });
    // setState(() {});
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      widget.onTimeChange.call(picked);
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    if (dayAbbreviations.isEmpty) return CircularProgressIndicator();

    return SimpleDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(Dimens.paddingXLarge),
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      children: [
        Column(
          children: [
            SizedBox(
              width: mediaQuerySize.width,
              height: mediaQuerySize.height/2.5,
              child: Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.all(Dimens.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.create_routine,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),

                      SizedBox(height: 16),

                      /// Time Picker
                      Text(AppLocalizations.of(context)!.hour, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            selectedTime.format(context),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      /// Week Days
                      Text(AppLocalizations.of(context)!.days_of_week, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: List.generate(dayAbbreviations.length, (index) {
                          bool isSelected = selectedDays[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDays[index] = !isSelected;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: isSelected ? Colors.green[900] : Colors.white,
                              radius: 20,
                              child: Text(
                                dayAbbreviations[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
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
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
          child: SaveButton(
            text: AppLocalizations.of(context)!.save,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ]
    );
  }
}