import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class UndoFavoriteDialog extends StatelessWidget {
  final String title;
  final Function onUndoFavorite;

  const UndoFavoriteDialog({
    Key? key,
    required this.title,
    required this.onUndoFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    return SimpleDialog(
      children: [
        Container(
          color: Colors.grey[200],
          width: mediaQuerySize.width,
          height: mediaQuerySize.height/2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.highlight_remove_rounded,),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(Dimens.marginNormal),
                child: Text(
                  '${AppLocalizations.of(context)!.remove_favorite_question} $title?',
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: Dimens.marginSmall),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginSmall),
                      child: ElevatedButton(
                        onPressed: () => onUndoFavorite.call(),
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.remove),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
  
}