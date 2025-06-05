import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/utils/dimens.dart';

class NutrientRow extends StatelessWidget {
  final String label;
  final String value;

  const NutrientRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.padding6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: Dimens.fontSizeSmall, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(value,
                  style: const TextStyle(fontSize: Dimens.fontSizeSmall, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Divider(color: Colors.white, thickness: 1, height: 1),
      ],
    );
  }
}
