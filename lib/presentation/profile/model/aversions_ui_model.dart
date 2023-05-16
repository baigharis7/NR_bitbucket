import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';

class AversionsUIModel {
  final List<FoodGroup> foodGroups;

  AversionsUIModel({
    required this.foodGroups,
  });
}

class FoodGroup {
  final int id;
  final String name;
  final List<SimpleItem> foodsList;

  FoodGroup({
    required this.id,
    required this.name,
    required this.foodsList,
  });
}

