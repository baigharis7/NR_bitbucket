import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
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
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      children: [
        SizedBox(
          width: mediaQuerySize.width,
          height: mediaQuerySize.height/1.5,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.clear,),
                ),
              ),
              Expanded(child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge),
                child: Column(children: [
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(right: Dimens.marginNormal, left: Dimens.marginNormal, top: Dimens.marginNormal, bottom: Dimens.marginXXXXLarge),
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
                  const Spacer(),
                  RoundedCustomButton(
                    buttonText: AppLocalizations.of(context)!.add_comment,
                    onPressed: () => widget.onSaveClick.call(),
                  ),
                ],),
              ),),
            ],
          ),
        ),
      ],
    );
  }
}