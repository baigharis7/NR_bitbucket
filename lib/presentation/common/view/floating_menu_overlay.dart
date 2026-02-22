import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/favorites_tab_holder.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/routines_tab_holder.dart';

class FloatingMenuOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final List<Map<String, dynamic>> menuItems;
  final bool showFavoritesRoutinesButtons;
  final bool centered;

  const FloatingMenuOverlay({
    super.key,
    required this.onClose,
    required this.menuItems,
    this.showFavoritesRoutinesButtons = true,
    this.centered = false,
  });

  @override
  State<FloatingMenuOverlay> createState() => _FloatingMenuOverlayState();
}

class _FloatingMenuOverlayState extends State<FloatingMenuOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _closeMenu() async {
    await _fadeController.reverse();
    widget.onClose();
  }

  Widget buildMenuItem(String label, String icon, Function onTap, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.2 * (index + 1)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      )),
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.margin6,),
          child: Row(
            mainAxisAlignment: widget.centered ? MainAxisAlignment.center : MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  _closeMenu();
                  onTap.call();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                  ),
                  child: Text(label, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black)),
                ),
              ),
              InkWell(
                onTap: () {
                  _closeMenu();
                  onTap.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(Dimens.padding6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                  ),
                  child: Image.asset(icon, width: 40, height: 40,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // final List<Map<String, dynamic>> menuItems = [
  //   {'label': 'Desayuno', 'icon': Icons.free_breakfast},
  //   {'label': 'Comida', 'icon': Icons.lunch_dining},
  //   {'label': 'Cena', 'icon': Icons.dinner_dining},
  //   {'label': 'Snacks', 'icon': Icons.fastfood},
  //   {'label': 'Actividad física', 'icon': Icons.fitness_center},
  //   {'label': 'Heces y orina', 'icon': Icons.wc},
  //   {'label': 'Suplementos', 'icon': Icons.medical_services},
  // ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            _closeMenu();
            return false;
          },
          child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Stack(
                alignment: widget.centered ? Alignment.center : Alignment.bottomRight,
                children: [
                  // Background blur with fade
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: AppColors.whit),
                    ),
                  ),

                  // Menu items
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.margin156),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimens.padding4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: widget.centered ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                        children: [
                          if (widget.showFavoritesRoutinesButtons) SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.2 * (7 + 1)),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _fadeController,
                              curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
                            )),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.yellowishGreen,
                                      borderRadius: BorderRadius.circular(Dimens.border50),
                                    ),
                                    child: ListTile(
                                      onTap: () { _closeMenu(); Navigator.pushNamed(context, RoutinesTabHolder.routeName); },
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border50)),
                                      visualDensity: VisualDensity.compact,
                                      horizontalTitleGap: Dimens.zero,
                                      tileColor: Colors.black,
                                      leading: Image.asset('assets/icon/routine_icon.png', width: 22, height: 22, color: Colors.white),
                                      title: Text(AppLocalizations.of(context)!.routines, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.white),),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: Dimens.width12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.yellowishGreen,
                                      borderRadius: BorderRadius.circular(Dimens.border50),
                                    ),
                                    child: ListTile(
                                      onTap: () { _closeMenu(); Navigator.pushNamed(context, FavoritesTabHolder.routeName);},
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border50)),
                                      visualDensity: VisualDensity.compact,
                                      horizontalTitleGap: Dimens.zero,
                                      tileColor: Colors.black,
                                        leading: InkWell(
                                          onTap: () {

                                          },
                                            child: Image.asset('assets/images/favorite_icon.png', width: 22, height: 22, color: Colors.white),
                                        ),
                                        title: Text(AppLocalizations.of(context)!.favorites, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.showFavoritesRoutinesButtons) const SizedBox(height: Dimens.height32),
                          ...List.generate(widget.menuItems.length, (i) {
                            final item = widget.menuItems[i];
                            return buildMenuItem(item['label'], item['icon'], item['onTap'], widget.menuItems.length - i);
                          }),
                          const SizedBox(height: Dimens.height32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}
