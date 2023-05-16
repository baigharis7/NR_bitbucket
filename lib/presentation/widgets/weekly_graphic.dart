import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/base_fill_vertical_bar.dart';

class WeeklyGraphic extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeeklyGraphic({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...data.map((dayDataMap) =>
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                    child: SizedBox(
                        height: 70,
                        child: BaseFillVerticalBar(fractionToFill: dayDataMap['kcal'] as double),
                    ),
                  ),
              )
            ],
          ),
        ),
        Container(
          color: Colors.black,
          height: 1,
          width: 250,
        ),
        SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...DateTimeHelper().getWeekDaysInitialList(context).map((item) =>
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                    child: Text(item),
                  ),
              ).toList()
            ],
          ),
        )
      ],
    );
  }

}