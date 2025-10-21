import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/utils/dimens.dart';

class ItemsSearchViewBuilder extends StatelessWidget {
  final List<String> options;
  final Function(String) onSelected;
  const ItemsSearchViewBuilder({super.key, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXXLarge),
      height: 100,
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 4.0,
          clipBehavior: Clip.hardEdge,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: Dimens.height_220),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: Dimens.paddingXLarge),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - Dimens.margin_60, maxHeight: Dimens.height170,), // Adjust the width as needed
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(options.length, (index) {
                    return InkWell(
                      onTap: () => onSelected.call(options[index]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.marginXSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                              child: Text(
                                options.elementAt(index),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimens.fontSizeLarge,
                                    color: Colors.black
                                ),
                              ),
                            ),
                            if (index < options.length - 1) ...[
                              const Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}