import 'package:flutter/cupertino.dart';

import 'floating_menu_overlay.dart';

class FloatingMenuController {
  OverlayEntry? _overlayEntry;

  void show(
    BuildContext context,
    List<Map<String, dynamic>> menuItems, {
    bool showFavoritesRoutinesButtons = true,
  }) {
    if (_overlayEntry != null) return;

    _overlayEntry = _buildOverlayEntry(context, menuItems, showFavoritesRoutinesButtons);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry(
    BuildContext context,
    List<Map<String, dynamic>> menuItems,
    bool showFavoritesRoutinesButtons,
  ) {
    return OverlayEntry(
      builder: (context) => FloatingMenuOverlay(
        onClose: hide,
        menuItems: menuItems,
        showFavoritesRoutinesButtons: showFavoritesRoutinesButtons,
      ),
    );
  }
}
