import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddFoodNameDialog extends StatefulWidget {
  final Function onNameChange;
  final Function onFinish;
  final Function onPop;
  final String title;

  const AddFoodNameDialog({
    Key? key,
    required this.onNameChange,
    required this.onFinish,
    required this.onPop,
    required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodNameDialogState();
}

class _AddFoodNameDialogState extends State<AddFoodNameDialog> {
  final List<String> mealTimes = MealTime.getAllMealTimes().map((mealTime) => mealTime.name.orEmpty()).toList();
  final _foodNameController = TextEditingController();
  String? _mealTime;

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    return SimpleDialog(
      backgroundColor: Colors.grey[200],
      children: [
        SizedBox(
          width: mediaQuerySize.width,
          height: mediaQuerySize.height/2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => widget.onPop.call(),
                      icon: const Icon(Icons.clear,),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                      left: Dimens.marginNormal,
                      right: Dimens.marginNormal,
                      top: Dimens.marginNormal,
                    ),
                    child: Text(
                      widget.title.appendColon(),
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeMedium,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(Dimens.marginNormal),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.write_here_hint,
                      ),
                      controller: _foodNameController,
                      onChanged: (foodName) => widget.onNameChange.call(foodName),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                child: RoundedCustomButton(
                  buttonText: AppLocalizations.of(context)!.save,
                  onPressed: () {
                    if (_foodNameController.text == '') {
                      ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                    } else {
                      widget.onFinish.call();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}