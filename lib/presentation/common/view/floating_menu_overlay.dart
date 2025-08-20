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

  const FloatingMenuOverlay({super.key, required this.onClose, required this.menuItems});

  @override
  State<FloatingMenuOverlay> createState() => _FloatingMenuOverlayState();
}

class _FloatingMenuOverlayState extends State<FloatingMenuOverlay> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _fabRotationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fabRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _fabRotationController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _fabRotationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fabRotationController.dispose();
    super.dispose();
  }

  void _closeMenu() async {
    await Future.wait([
      _fadeController.reverse(),
      _fabRotationController.reverse(),
    ]);
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
        child: InkWell(
          onTap: () { _closeMenu(); onTap.call();},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.margin6,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge),
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingNormal),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                  ),
                  child: Text(label, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.black)),
                ),
                Container(
                  padding: const EdgeInsets.all(Dimens.padding6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 6))],
                  ),
                  child: Image.asset(icon, width: 40, height: 40,),
                ),
              ],
            ),
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
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Stack(
                alignment: Alignment.bottomRight,
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
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.margin156),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SlideTransition(
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
                                      leading: Image.asset('assets/images/favorite_icon.png', width: 22, height: 22, color: Colors.white),
                                      title: Text(AppLocalizations.of(context)!.favorites, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, color: Colors.white),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimens.height32),
                        ...List.generate(widget.menuItems.length, (i) {
                          final item = widget.menuItems[i];
                          return buildMenuItem(item['label'], item['icon'], item['onTap'], widget.menuItems.length - i);
                        }),
                        const SizedBox(height: Dimens.height32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: Dimens.margin62),
            child: FloatingActionButton(
              clipBehavior: Clip.hardEdge,
              onPressed: _closeMenu,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.greenCyan, AppColors.bluishGreen], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7])),
                  child: const Icon(Icons.add),
                ),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 6.28,
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
