import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

part 'meal_time.g.dart';

@JsonSerializable(explicitToJson: true)
class MealTime {
  int? id;
  String? name;
  String? time;

  MealTime({this.id, this.name, this.time});

  static List<MealTime> getAllMealTimes() {
    return [
      Breakfast(),
      Lunch(),
      Dinner(),
      Snack(),
    ];
  }

  factory MealTime.fromJson(Map<String, dynamic> json) => _$MealTimeFromJson(json);
  Map<String, dynamic> toJson() => _$MealTimeToJson(this);
}

class Breakfast extends MealTime {
  Breakfast() : super(id: 0, name: AppLocalizationsHelper.instance.translate('breakfast'), time: '07:30');
}

class Lunch extends MealTime {
  Lunch() : super(id: 1, name: AppLocalizationsHelper.instance.translate('lunch'), time: '01:30');
}

class Dinner extends MealTime {
  Dinner() : super(id: 2, name: AppLocalizationsHelper.instance.translate('dinner'), time: '08:30');
}

class Snack extends MealTime {
  Snack() : super(id: 3, name: AppLocalizationsHelper.instance.translate('snack'), time: '');
}

