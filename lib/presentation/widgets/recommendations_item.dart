import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/square_checkbox.dart';

class RecommendationsItem extends StatefulWidget {
  final FoodItemMaster foodItemMaster;
  final Function onAlternative;
  final Function onAdd;
  final bool isChecked;
  final bool? isFrequent;

  const RecommendationsItem({
    Key? key,
    required this.foodItemMaster,
    required this.onAlternative,
    required this.onAdd,
    required this.isChecked,
    this.isFrequent = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsItemState();

}

class _RecommendationsItemState extends State<RecommendationsItem> {
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              widget.foodItemMaster.translate(context),
              overflow: TextOverflow.clip,
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: IconButton(
          //     icon: const Icon(
          //       Icons.arrow_drop_down,
          //       size: 28,
          //     ),
          //     onPressed: () => widget.onAlternative.call(),
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareCheckbox(
                  isChecked: widget.isChecked,
                  onChanged: () => widget.onAdd.call(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}