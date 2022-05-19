import 'package:flutter/material.dart';

class DatePickerHelper {

  static void presentDatePicker(BuildContext context, StateSetter state, Function saveDate) {
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
      state(() => saveDate.call(pickedDate));
    });
  }

}