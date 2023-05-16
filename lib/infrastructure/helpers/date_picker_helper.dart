import 'package:flutter/material.dart';

class DatePickerHelper {

  static void presentDatePicker(
      {required BuildContext context, required Function saveDate,}) {
    DateTime currentMoment = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: currentMoment,
      firstDate: DateTime(currentMoment.year - 100),
      lastDate: currentMoment,
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      saveDate.call(pickedDate);
    });
  }

  static void presentTimePicker({required BuildContext context, required Function saveDate}) async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (picked != null) {
      saveDate.call(picked);
    }
  }
}