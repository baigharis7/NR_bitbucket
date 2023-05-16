import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;

  const ConfirmationDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(Dimens.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: Dimens.marginXXLarge+10, right: Dimens.marginXXLarge+10, bottom: Dimens.marginLarge),
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: Dimens.fontSizeXXLarge,
                  color: Colors.black,
                ),
                child: Text(
                  message,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Center(
              child: Icon(Icons.check_circle_outline, size: 88, color: Colors.teal,),
            )
          ],
        ),
      ),
    );
  }

}