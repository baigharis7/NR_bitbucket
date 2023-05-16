import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

part 'meal_time.g.dart';

@JsonSerializable(explicitToJson: true)
class MealTime {
  int? id;
  String? name;

  MealTime({this.id, this.name});

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
  Breakfast() : super(id: 0, name: AppLocalizationsHelper.instance.translate('breakfast'));
}

class Lunch extends MealTime {
  Lunch() : super(id: 1, name: AppLocalizationsHelper.instance.translate('lunch'));
}

class Dinner extends MealTime {
  Dinner() : super(id: 2, name: AppLocalizationsHelper.instance.translate('dinner'));
}

class Snack extends MealTime {
  Snack() : super(id: 3, name: AppLocalizationsHelper.instance.translate('snack'));
}

