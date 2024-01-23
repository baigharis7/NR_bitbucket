import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/utils/dimens.dart';

class BoxTypeRadioTextWidget extends StatefulWidget {
  final Function onPressed;
  final bool isSelected;
  final String title;
  const BoxTypeRadioTextWidget({super.key, required this.onPressed, required this.isSelected, required this.title});

  @override
  State<BoxTypeRadioTextWidget> createState() => _BoxTypeRadioTextWidgetState();
}

class _BoxTypeRadioTextWidgetState extends State<BoxTypeRadioTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12)),
        child: InkWell(
          onTap: () => widget.onPressed.call(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall -4, horizontal: Dimens.paddingSmall -2),
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall, vertical: Dimens.marginNormal),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: Dimens.marginNormal),
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeMedium,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: Dimens.marginNormal),
                  child: Container(
                    height: 21,
                    width: 21,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: Dimens.borderSmall,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}