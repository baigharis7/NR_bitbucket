import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/favorites_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurinedetails/view/feces_urine_tabs.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/common/view/recipe_tabs_holder.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/view/recommendations_tabs_holder.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/routines_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

const _kNavColor = Color(0xFF28421D);

class CustomBottomNaviBarWidget extends StatefulWidget {
  final int activePosition;
  final DateTime? selectedDateTime;

  const CustomBottomNaviBarWidget({
    super.key,
    required this.activePosition,
    this.selectedDateTime,
  });

  @override
  State<CustomBottomNaviBarWidget> createState() =>
      _CustomBottomNaviBarWidgetState();
}

class _CustomBottomNaviBarWidgetState extends State<CustomBottomNaviBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _menuAnimController;
  late AnimationController _plusAnimController;

  @override
  void initState() {
    super.initState();
    _menuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _plusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuAnimController.dispose();
    _plusAnimController.dispose();
    _scrimEntry?.remove();
    _menuEntry?.remove();
    _plusScrimEntry?.remove();
    _plusMenuEntry?.remove();
    _plusBtnOverlay?.remove();
    super.dispose();
  }

  // ── Shared plus-button overlay (sits on top of any menu) ──────────
  OverlayEntry? _plusBtnOverlay;

  OverlayEntry _buildPlusButtonOverlay({
    required double bottomPadding,
    AnimationController? animController,
    required VoidCallback onTap,
  }) {
    final icon = animController != null
        ? RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.125).animate(
              CurvedAnimation(parent: animController, curve: Curves.easeInOut),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          )
        : const Icon(Icons.add, color: Colors.white, size: 32);

    return OverlayEntry(
      builder: (_) => Positioned(
        bottom: bottomPadding + 15,
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.greenCyan, AppColors.bluishGreen],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.7],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5015A95F),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  // ── + button overlay panel ─────────────────────────────────────────
  bool _plusOpen = false;
  OverlayEntry? _plusScrimEntry;
  OverlayEntry? _plusMenuEntry;


  void _onPlusTap() {
    if (_plusOpen) {
      _closePlusMenu();
    } else {
      _openPlusMenu();
    }
  }

  void _openPlusMenu() {
    // Close the hamburger menu if open
    _closeMenu();

    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final selectedDateTime = widget.selectedDateTime ?? DateTime.now();

    final mealItems = MealTime.getAllMealTimes().map((e) => {
      'label': e.name,
      'icon': 'assets/images/meal_time_${e.id.orZero()}.png',
      'onTap': () {
        _closePlusMenu();
        Navigator.pushNamed(
          context,
          AddFoodEventScreen.routeName,
          arguments: FoodArgumentsModel(
            mealTime: e,
            selectedDateTime: selectedDateTime,
          ),
        );
      },
    }).toList();

    final otherItems = [
      {
        'label': l10n.supplements,
        'icon': 'assets/images/supplement.png',
        'onTap': () { _closePlusMenu(); Navigator.pushNamed(context, SupplementsScreen.routeName); },
      },
      {
        'label': l10n.physical_activity,
        'icon': 'assets/images/sport.png',
        'onTap': () { _closePlusMenu(); Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: selectedDateTime); },
      },
      {
        'label': l10n.faeces_urine,
        'icon': 'assets/images/feces_urine.png',
        'onTap': () { _closePlusMenu(); Navigator.pushNamed(context, FecesUrineTabs.routeName); },
      },
    ];

    setState(() {
      _plusOpen = true;
      _plusAnimController.forward();
    });

    // Scrim to dismiss on tap — stops above the navbar
    _plusScrimEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 65 + bottomPadding,
        child: GestureDetector(
          onTap: _closePlusMenu,
          behavior: HitTestBehavior.opaque,
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );

    // Menu panel positioned above the navbar
    _plusMenuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 65 + 8 + bottomPadding,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _plusAnimController,
            curve: Curves.easeInOut,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 38),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Food section label
                Text(
                  l10n.food,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: _kNavColor,
                    fontSize: Dimens.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Meal time items in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: mealItems.map((item) => _PlusGridItem(
                    label: item['label'] as String,
                    assetIcon: item['icon'] as String,
                    onTap: item['onTap'] as VoidCallback,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                // Divider
                Divider(color: _kNavColor.withOpacity(0.3), height: 1),
                const SizedBox(height: 16),
                // Other items in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: otherItems.map((item) => _PlusGridItem(
                    label: item['label'] as String,
                    assetIcon: item['icon'] as String,
                    onTap: item['onTap'] as VoidCallback,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _plusBtnOverlay = _buildPlusButtonOverlay(
      bottomPadding: bottomPadding,
      animController: _plusAnimController,
      onTap: _closePlusMenu,
    );

    final overlay = Overlay.of(context);
    overlay.insertAll([_plusScrimEntry!, _plusMenuEntry!, _plusBtnOverlay!]);
  }

  void _closePlusMenu() {
    if (!_plusOpen) return;
    setState(() {
      _plusOpen = false;
    });
    _plusAnimController.reverse().then((_) {
      _plusScrimEntry?.remove();
      _plusScrimEntry = null;
      _plusMenuEntry?.remove();
      _plusMenuEntry = null;
      _plusBtnOverlay?.remove();
      _plusBtnOverlay = null;
    });
  }

  // ── Menu panel ────────────────────────────────────────────────────────
  bool _menuOpen = false;
  OverlayEntry? _scrimEntry;
  OverlayEntry? _menuEntry;

  void _toggleMenu() {
    if (_menuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    // Close the plus menu if open
    _closePlusMenu();

    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    setState(() {
      _menuOpen = true;
      _menuAnimController.forward();
    });

    _scrimEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 65 + bottomPadding,
        child: GestureDetector(
          onTap: _closeMenu,
          behavior: HitTestBehavior.opaque,
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );

    _menuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 65 + 8 + bottomPadding,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _menuAnimController,
            curve: Curves.easeInOut,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 38),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuGridItem(
                      icon: Icons.history,
                      label: l10n.routines,
                      onTap: () => _navigateFromMenu(RoutinesTabHolder.routeName),
                    ),
                    const SizedBox(width: 24),
                    _MenuGridItem(
                      icon: Icons.star_outline_rounded,
                      label: l10n.favorites,
                      onTap: () => _navigateFromMenu(FavoritesTabHolder.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MenuSvgItem(
                      svgAsset: 'assets/images/tips.svg',
                      label: l10n.tips,
                      onTap: () => _navigateFromMenu(RecommendationsTabHolder.routeName),
                    ),
                    _MenuSvgItem(
                      svgAsset: 'assets/images/recipes.svg',
                      label: l10n.recipes,
                      onTap: () => _navigateFromMenu(RecipesTabsHolder.routeName),
                    ),
                    _MenuSvgItem(
                      svgAsset: 'assets/images/profile.svg',
                      label: l10n.profile,
                      onTap: () => _navigateFromMenu(ProfileScreen.routeName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _plusBtnOverlay = _buildPlusButtonOverlay(
      bottomPadding: bottomPadding,
      onTap: _closeMenu,
    );

    final overlay = Overlay.of(context);
    overlay.insertAll([_scrimEntry!, _menuEntry!, _plusBtnOverlay!]);
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() {
      _menuOpen = false;
    });
    _menuAnimController.reverse().then((_) {
      _scrimEntry?.remove();
      _scrimEntry = null;
      _menuEntry?.remove();
      _menuEntry = null;
      _plusBtnOverlay?.remove();
      _plusBtnOverlay = null;
    });
  }

  void _navigateFromMenu(String routeName) {
    _closeMenu();
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 65 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The bar with notch cutout around the + button
          Positioned.fill(
            child: CustomPaint(
              painter: _NotchedBarPainter(
                color: Colors.white.withOpacity(0.95),
                notchRadius: 42,
                cornerRadius: 20,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Row(
                  children: [
                    // Dashboard
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _closeMenu();
                          _closePlusMenu();
                          if (ModalRoute.of(context)?.settings.name !=
                              DashboardScreen.routeName) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              DashboardScreen.routeName,
                              (route) => false,
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 28,
                              child: SvgPicture.asset(
                                'assets/images/start.svg',
                                colorFilter: ColorFilter.mode(
                                  widget.activePosition == 0
                                      ? _kNavColor
                                      : AppColors.cloudyGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.start,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: widget.activePosition == 0
                                    ? _kNavColor
                                    : AppColors.cloudyGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Space for center button
                    const SizedBox(width: 80),

                    // Menu
                    Expanded(
                      child: InkWell(
                        onTap: _toggleMenu,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedIcon(
                              icon: AnimatedIcons.menu_close,
                              progress: _menuAnimController,
                              color: _kNavColor,
                              size: 26,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.menu,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: _kNavColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Center + button (hidden when overlay button is showing)
          if (!_plusOpen && !_menuOpen) Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _onPlusTap,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.greenCyan, AppColors.bluishGreen],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.0, 0.7],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x5015A95F),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: _plusOpen ? 0.125 : 0, // 45 degrees = + becomes ×
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  final Color color;
  final double notchRadius;
  final double cornerRadius;

  _NotchedBarPainter({
    required this.color,
    required this.notchRadius,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.black25Percent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final centerX = size.width / 2;
    // Button: 72x72, bump rises above bar top
    const bumpPeek = 26.0;
    // Half-width of the bump area — narrower to hug tighter
    const bumpHalfWidth = 39.0;

    // Shadow path: rounded top corners with bump (for the shadow outline)
    final shadowPath = Path();
    shadowPath.moveTo(0, cornerRadius);
    shadowPath.quadraticBezierTo(0, 0, cornerRadius, 0);
    shadowPath.lineTo(centerX - bumpHalfWidth, 0);
    shadowPath.cubicTo(
      centerX - bumpHalfWidth * 0.73, -bumpPeek * 0.62,
      centerX - bumpHalfWidth * 0.38, -bumpPeek,
      centerX, -bumpPeek,
    );
    shadowPath.cubicTo(
      centerX + bumpHalfWidth * 0.38, -bumpPeek,
      centerX + bumpHalfWidth * 0.73, -bumpPeek * 0.62,
      centerX + bumpHalfWidth, 0,
    );
    shadowPath.lineTo(size.width - cornerRadius, 0);
    shadowPath.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(0, size.height);
    shadowPath.close();

    // Fill path: full rectangle with bump (no rounded corners — avoids
    // transparent corner gaps that show the dark background behind)
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(centerX - bumpHalfWidth, 0);
    path.cubicTo(
      centerX - bumpHalfWidth * 0.73, -bumpPeek * 0.62,
      centerX - bumpHalfWidth * 0.38, -bumpPeek,
      centerX, -bumpPeek,
    );
    path.cubicTo(
      centerX + bumpHalfWidth * 0.38, -bumpPeek,
      centerX + bumpHalfWidth * 0.73, -bumpPeek * 0.62,
      centerX + bumpHalfWidth, 0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw rounded shadow first, then the full fill
    canvas.drawPath(shadowPath.shift(const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) =>
      color != oldDelegate.color ||
      notchRadius != oldDelegate.notchRadius ||
      cornerRadius != oldDelegate.cornerRadius;
}

class _MenuGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuGridItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _kNavColor.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(icon, color: _kNavColor.withOpacity(0.8), size: 36),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: _kNavColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSvgItem extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback onTap;

  const _MenuSvgItem({
    required this.svgAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: SvgPicture.asset(
                svgAsset,
                colorFilter: const ColorFilter.mode(_kNavColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: _kNavColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusGridItem extends StatelessWidget {
  final String label;
  final String assetIcon;
  final VoidCallback onTap;

  const _PlusGridItem({
    required this.label,
    required this.assetIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _kNavColor.withOpacity(0.3), width: 1.5),
              ),
              child: Center(
                child: Image.asset(assetIcon, width: 38, height: 38),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: _kNavColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
