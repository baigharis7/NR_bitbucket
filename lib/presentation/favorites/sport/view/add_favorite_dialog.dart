import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddFavoriteDialog extends StatefulWidget {
  final Function onNameChange;
  final Function onFinish;
  final Function onPop;

  const AddFavoriteDialog({
    Key? key,
    required this.onNameChange,
    required this.onFinish,
    required this.onPop,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFavoriteDialog();

}

class _AddFavoriteDialog extends State<AddFavoriteDialog> {
  final _sportNameController = TextEditingController();

  @override
  void dispose() {
    _sportNameController.dispose();
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
                    margin: const EdgeInsets.all(Dimens.marginNormal),
                    child: Text(AppLocalizations.of(context)!.sport_name),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(Dimens.marginNormal),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.write_here_hint,
                      ),
                      controller: _sportNameController,
                      onChanged: (foodName) => widget.onNameChange.call(foodName),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                child: RoundedCustomButton(
                  buttonText: AppLocalizations.of(context)!.save_favorite,
                  onPressed: () {
                    if (_sportNameController.text == '') {
                      ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                    } else {
                      widget.onFinish.call();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}