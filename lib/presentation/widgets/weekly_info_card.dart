import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/weekly_graphic.dart';

class WeeklyInfoCard extends StatelessWidget {
  final int kcals;
  final List<Map<String, dynamic>> weeklyData;
  final double? cardElevation;

  const WeeklyInfoCard({Key? key, required this.kcals, required this.weeklyData, this.cardElevation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: cardElevation,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall, horizontal: Dimens.marginNormal),
                child: Text('$kcals kcal'),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                  child: WeeklyGraphic(data: weeklyData,),
              )
            ],
          ),
        ),
      ),
    );
  }

}