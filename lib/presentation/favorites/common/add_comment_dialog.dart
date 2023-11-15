import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddCommentDialog extends StatefulWidget {
  final Function onEdit;
  final Function onSaveClick;

  const AddCommentDialog({
    Key? key,
    required this.onEdit,
    required this.onSaveClick,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddCommentDialogState();
}

class _AddCommentDialogState extends State<AddCommentDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
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
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.clear,),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 100,
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enter,
                          ),
                          controller: _commentController,
                          onChanged: (comment) {
                            widget.onEdit.call(comment);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: RoundedCustomButton(
                  buttonText: AppLocalizations.of(context)!.add_comment,
                  onPressed: () => widget.onSaveClick.call(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}