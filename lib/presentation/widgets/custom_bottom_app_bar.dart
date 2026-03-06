import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/journal/view/journal_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/view/recommendations_tabs_holder.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Function? initStateCallback;
  const CustomBottomAppBar({Key? key, required this.initStateCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BottomAppBar(
      notchMargin: 3.0,
      color: Colors.white,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(),
        StadiumBorder(),
      ),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              child: Container(
                margin: const EdgeInsets.fromLTRB(Dimens.marginXLarge, Dimens.marginSmall, Dimens.marginSmall, Dimens.marginNormal),
                child: InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)!.settings.name != JournalScreen.routeName) {
                      Navigator.popAndPushNamed(context, JournalScreen.routeName).then((value) => initStateCallback?.call());
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: Dimens.marginNormal),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/icon/journal_icon.png',
                          color: Colors.black,
                          height: 32,
                          width: 32,
                        ),
                        Text(
                          AppLocalizations.of(context)!.journal,
                          style: const TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            FittedBox(
              child: Container(
                margin: const EdgeInsets.only(right: Dimens.marginXLarge*2),
                child: InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)!.settings.name != RecommendationsTabHolder.routeName) {
                      Navigator.popAndPushNamed(context, RecommendationsTabHolder.routeName).then((value) => initStateCallback?.call());
                    }
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icon/tips_icon.png',
                        color: Colors.black,
                        height: 32,
                        width: 32,
                      ),
                      Text(
                        AppLocalizations.of(context)!.tips,
                        style: const TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}