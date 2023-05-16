import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class DietQuestionsHeader extends StatelessWidget {
  final String title;

  const DietQuestionsHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: Dimens.marginSmall),
              child: Text(
                AppLocalizations.of(context)!.diet,
                style: const TextStyle(
                  fontSize: Dimens.fontSizeXXLarge,
                ),
              ),
            ),
            Image.asset('assets/icon/spoon_sugar_icon.png')
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
              left: Dimens.marginNormal,
              bottom: Dimens.marginXXLarge,
              top: Dimens.marginXLarge,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }


}