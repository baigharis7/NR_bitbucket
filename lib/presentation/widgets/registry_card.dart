import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO: fix sizes, to make it constant. Cristina.
class RegistryCard extends StatelessWidget {
  final String title;
  final Function onClick;
  final String? innerMessage;
  final bool showCompleted;

  const RegistryCard({Key? key, required this.title, required this.onClick, this.innerMessage, this.showCompleted = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: Dimens.borderSmall,
        ),
        borderRadius:  const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  onClick.call();
                },
              )
            ],
          ),
          if (innerMessage != null) Container(
            decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      innerMessage.orEmpty(),
                      style: TextStyle(
                        fontSize: showCompleted ? 50 : Dimens.fontSizeNormal,
                      ),
                    ),
                  ),
                  if (showCompleted) Text(AppLocalizations.of(context)!.completed)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}