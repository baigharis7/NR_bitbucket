import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

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
  final Widget? child;
  final String? backgroundImage;
  final String? searchHintText;
  final ValueChanged<FocusNode>? onFocusNodeCreated;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onScanTap;
  const HeaderAddItemCardSection({super.key, this.title, this.onBackTap, this.image, this.items, this.onItemSelect, this.path, this.child, this.backgroundImage, this.searchHintText, this.onFocusNodeCreated, this.icon, this.iconColor, this.onScanTap});

  @override
  State<HeaderAddItemCardSection> createState() => _HeaderAddItemCardSectionState();
}

class _HeaderAddItemCardSectionState extends State<HeaderAddItemCardSection> {
  final TextEditingController _foodInputController = TextEditingController();
  final FocusNode _focusInputController = FocusNode();
  final GlobalKey _inputKey = GlobalKey();
  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFocusNodeCreated?.call(_focusInputController);
    });
  }

  @override
  void dispose() {
    _foodInputController.dispose();
    _focusInputController.dispose();
    super.dispose();
  }

  double _calculateMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Get input field position
    final RenderBox? renderBox = _inputKey.currentContext?.findRenderObject() as RenderBox?;
    final inputPosition = renderBox?.localToGlobal(Offset.zero).dy ?? 200;
    final inputHeight = renderBox?.size.height ?? 50;

    // Available space = screen - keyboard - input position - input height - gap from keyboard
    final availableHeight = screenHeight - keyboardHeight - inputPosition - inputHeight - 8;

    return availableHeight.clamp(150.0, availableHeight);
  }

  List<String> _filterAndSortSuggestions(String pattern) {
    if (pattern.isEmpty) return [];

    final filtered = widget.items.orEmpty()
        .where((option) => removeDiacritics(option).toLowerCase()
            .contains(removeDiacritics(pattern.toLowerCase())))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return filtered;
  }

  Map<String, List<String>> _groupByFirstLetter(List<String> items) {
    final grouped = <String, List<String>>{};
    for (final item in items) {
      if (item.isNotEmpty) {
        final letter = item[0].toUpperCase();
        grouped.putIfAbsent(letter, () => []).add(item);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: Dimens.paddingLarge, right: Dimens.paddingLarge, bottom: Dimens.paddingLarge, top: Dimens.paddingNormal),
      decoration: BoxDecoration(
        color: const Color(0xFF28421D).withOpacity(0.59),
        borderRadius: BorderRadius.circular(16),
        image: !widget.backgroundImage.isNull() ? DecorationImage(image: AssetImage(widget.backgroundImage!), fit: BoxFit.cover, opacity: 0.40,) : null,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.title ?? '',
                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize21,),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onScanTap != null) GestureDetector(
                    onTap: widget.onScanTap,
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.mountainMeadow.withOpacity(0.85),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                    ),
                  ),
                  if (widget.icon != null) Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                    ),
                    child: Icon(widget.icon, size: 42, color: widget.iconColor ?? Colors.white),
                  )
                  else if (widget.image.isNotNull()) Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                    ),
                    child: Image.asset(widget.image ?? 'assets/images/meal_time_0.png', height: 52, width: 52),
                  ),
                ],
              ),
            ],
          ),
          if (widget.onItemSelect != null) const SizedBox(height: 16),
          if (widget.onItemSelect != null) TypeAheadField<String>(
            key: _inputKey,
            controller: _foodInputController,
            focusNode: _focusInputController,
            suggestionsCallback: (pattern) {
              // Requirement 1: Show popup only after 1+ characters
              if (pattern.length < 1) return [];
              _currentSuggestions = _filterAndSortSuggestions(pattern);
              return _currentSuggestions;
            },
            constraints: BoxConstraints(
              maxHeight: _calculateMaxHeight(context),
            ),
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                cursorWidth: Dimens.width1,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.white, size: 22),
                  prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
                  hintText: focusNode.hasFocus ? null : (widget.searchHintText ?? AppLocalizations.of(context)!.write_here_hint),
                  hintStyle: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w400),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.highlight_remove, color: Colors.white, size: 20),
                          onPressed: () {
                            controller.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              );
            },
            decorationBuilder: (context, child) {
              return Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                child: child,
              );
            },
            listBuilder: (context, children) {
              final grouped = _groupByFirstLetter(_currentSuggestions);
              final sortedLetters = grouped.keys.toList()..sort();

              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Requirement 4: Item count at top-right of menu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_currentSuggestions.length} ${_currentSuggestions.length > 1 ? AppLocalizations.of(context)!.items_found : AppLocalizations.of(context)!.item_found}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Requirements 2 & 5: Scrollable grouped list with alphabet headers
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: sortedLetters.length,
                          itemBuilder: (context, groupIndex) {
                            final letter = sortedLetters[groupIndex];
                            final itemsInGroup = grouped[letter]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Letter header (simple divider style)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  color: Colors.grey.shade200,
                                  width: double.infinity,
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Food items under this letter
                                ...itemsInGroup.map((item) {
                                  final itemIndex = _currentSuggestions.indexOf(item);
                                  if (itemIndex >= 0 && itemIndex < children.length) {
                                    return children[itemIndex];
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemBuilder: (context, suggestion) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              );
            },
            onSelected: (option) {
              widget.onItemSelect?.call(option, _focusInputController);
              _foodInputController.clear();
              _focusInputController.unfocus();
              setState(() {});
            },
            hideOnEmpty: true,
            hideOnLoading: true,
            debounceDuration: const Duration(milliseconds: 200),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
