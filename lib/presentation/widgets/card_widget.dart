import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/NutrientDetailWidget.dart';

import '../../infrastructure/utils/dimens.dart';

class CardWidget extends StatefulWidget {
  final String? title;
  final Function? screenToMove;
  final List<NutrientDetailWidget> children;

  const CardWidget(
      {super.key, this.title, this.screenToMove, required this.children});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: Dimens.marginLarge, vertical: Dimens.marginNormal),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title.orEmpty(),
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeNormal,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.screenToMove != null)
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        widget.screenToMove?.call();
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...widget.children,
        ],
      ),
    );
  }
}
