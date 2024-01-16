import 'package:flutter/material.dart';
import '../../domain/models/profile/feces.dart';
import '../../infrastructure/utils/dimens.dart';

class RadioTitleDescImage extends StatelessWidget {
  final bool isSelected;
  final Feces fece;
  final Function(int?) onSelect;

  const RadioTitleDescImage({super.key, required this.isSelected, required this.fece, required this.onSelect,});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
        child: InkWell(
          onTap: () => onSelect.call(fece.id),
          child: Row(
            children: [
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(right: Dimens.marginNormal),
                child: Container(
                  height: Dimens.heightXSmall - 2,
                  width: Dimens.heightXSmall - 2,
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
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(fece.title ?? ''),
                  if (fece.description?.isNotEmpty ?? false) Text(fece.description ?? ''),
                ],),
              ),
              if (fece.image?.isNotEmpty ?? false) Image.asset(fece.image!, width: 64, height: 44,),
            ],
          ),
        ),
      ),
    );
  }
}
