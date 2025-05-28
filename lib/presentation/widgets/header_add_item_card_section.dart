import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/items_search_view_builder_widget.dart';

import '../../infrastructure/helpers/remove_diac.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class HeaderAddItemCardSection extends StatefulWidget {
  final String? title;
  final Function? onBackTap;
  final String? image;
  final List<String>? items;
  final String? path;
  final Function(String, FocusNode)? onItemSelect;
  const HeaderAddItemCardSection({super.key, this.title, this.onBackTap, this.image, this.items, this.onItemSelect, this.path});

  @override
  State<HeaderAddItemCardSection> createState() => _HeaderAddItemCardSectionState();
}

class _HeaderAddItemCardSectionState extends State<HeaderAddItemCardSection> {
  TextEditingController _foodInputController = TextEditingController();
  late Object? arguments;
  late FocusNode _focusInputController;
  int filteredListLength = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.darkJungleGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => widget.onBackTap?.call(),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios, color: Colors.white, size: 15),
                    const Icon(Icons.home, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.path ?? AppLocalizations.of(context)!.start,
                      style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline, decorationThickness: 2,),
                    ),
                  ],
                ),
              ),
              if (widget.image.isNotNull()) Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                ),
                child: Image.asset(widget.image ?? 'assets/images/meal_time_0.png', height: 60, width: 60),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          if (widget.onItemSelect != null) Autocomplete<String>(
            fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
                ) {
              _foodInputController = textEditingController;
              _focusInputController = focusNode;
              return TextField(
                style: const TextStyle(color: Colors.white),
                showCursor: false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: AppLocalizations.of(context)!.write_here_hint,
                  hintStyle: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w400),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  suffixIcon: IconButton(
                    icon: textEditingController.text != ''
                        ? const Icon(
                      Icons.highlight_remove,
                      color: Colors.white,
                      size: 20,
                    )
                        : Container(),
                    onPressed: () => setState(() {
                      textEditingController.text = '';
                    }),
                  ),
                ),
                controller: textEditingController,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => _foodInputController.text.isNotEmptyOrNull() && _foodInputController.text.length > 2 ? Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal), child: Text('$filteredListLength: ' '${filteredListLength > 1 ? AppLocalizations.of(context)!.items_found : AppLocalizations.of(context)!.item_found}', style: const TextStyle(color: Colors.white),)) : Container(),
                focusNode: focusNode,
                onChanged: (value) {
                  setState(() {
                    textEditingController;
                  });
                },
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '' || textEditingValue.text.length < 3) return const Iterable<String>.empty();
              final filteredList =  widget.items.orEmpty()
                  .where((String option) => removeDiacritics(option).toLowerCase().contains(removeDiacritics(textEditingValue.text.toLowerCase())));
              filteredListLength = filteredList.length;
              return filteredList;
            },
            optionsViewBuilder: (context, onSelected, options) {
              return ItemsSearchViewBuilder(options: options.toList(), onSelected: onSelected,);
            },
            onSelected: (option) {
              widget.onItemSelect?.call(option, _focusInputController);
              _foodInputController.text = '';
            },
          ),
        ],
      ),
    );
  }
}
