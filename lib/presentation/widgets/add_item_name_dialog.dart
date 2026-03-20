import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';

import '../../infrastructure/helpers/toast_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../foodevent/bloc/add_food_event_bloc.dart';

class AddItemNameDialog extends StatefulWidget {
  final String title;
  final Function(String) onNameChange;
  final Function onSave;
  final Function onCancel;
  final String? eventName;
  final int itemsLength;
  const AddItemNameDialog({super.key,
    required this.title,
    required this.onNameChange,
    required this.onSave,
    required this.onCancel,
    this.eventName,
    this.itemsLength = 0,
  });

  @override
  State<AddItemNameDialog> createState() => _AddItemNameDialogState();
}

class _AddItemNameDialogState extends State<AddItemNameDialog> {
  late AddFoodEventBloc bloc;
  final _itemNameController = TextEditingController();

  @override
  void initState() {
    bloc = BlocProvider.of<AddFoodEventBloc>(context);
    _itemNameController.text = widget.eventName.orEmpty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              margin: const EdgeInsets.all(Dimens.marginXXLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.provide_name,
                      ),
                      controller: _itemNameController,
                      onChanged: (foodName) => widget.onNameChange.call(foodName),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(Dimens.marginNormal),
            child: GeneralButton(
              title: AppLocalizations.of(context)!.ok,
              onTap: () {
                if (widget.itemsLength > 1 && _itemNameController.text.isEmptyOrNull()) {
                  ToastHelper().showToast(text: AppLocalizations.of(context)!.provide_name);
                  return;
                }
                widget.onSave.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}