import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/nutrient_row.dart';
import '../../widgets/rounded_border_box.dart';
import '../../../infrastructure/utils/constants.dart';

class MealTimeItemScreen extends StatefulWidget {
  static const routeName = '/meal_time_item_screen';
  const MealTimeItemScreen({super.key});

  @override
  State<MealTimeItemScreen> createState() => _MealTimeItemScreenState();
}

class _MealTimeItemScreenState extends State<MealTimeItemScreen> {
  final nutrients = [
    {"label": "Fibra", "value": "12g"},
    {"label": "Azucar libre", "value": "23g"},
  ];

  final micronutrients = [
    {"label": "Vitamina B6", "value": "123g"},
    {"label": "Tipófano B12", "value": "123g"},
    {"label": "Zinc", "value": "123g"},
    {"label": "Vitamina E", "value": "123g"},
    {"label": "Hierro", "value": "123g"},
    {"label": "Calcio", "value": "123g"},
    {"label": "Magnesio", "value": "123g"},
    {"label": "Omega 3", "value": "123g"},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image or gradient
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'), // Your image
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0), // Needed to activate the blur
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimens.paddingNormal),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimens.padding10),
                    decoration: BoxDecoration(
                      color: AppColors.darkJungleGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(children: [
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        title: const Text('Lentejas', style: AppTextStyles.h3,),
                        trailing: const Icon(Icons.star_rounded, size: 21, color: Colors.white),
                      ),
                      const ListTile(visualDensity: VisualDensity.compact, title: Text('20 grams - Fried', style: AppTextStyles.subtitle2), ),
                      const Divider(height: 1, thickness: 1, color: Colors.white,),
                      const SizedBox(height: Dimens.height12),
                      Column(children: [
                        const Text('${350} Kcal', style: AppTextStyles.hh,),
                        Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),child: const Divider(color: Colors.white, height: 1, thickness: 1)),
                        Row(children: [
                          ...[].map((macroNutrient) {
                            return Expanded(
                              child: Column(children: [
                                Text(macroNutrient.nutrientInfoMaster.translate(context), style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall, fontWeight: FontWeight.w700)),
                                Text('${macroNutrient.quantityConsumed.toNutrientDisplay()}${macroNutrient.unit}', style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600, fontSize: Dimens.fontSize21)),
                              ],),
                            );
                          }),
                        ],),
                      ])
                    ]),
                  ),
                  const SizedBox(height: Dimens.height32),
                  Row(
                    children: [
                      Expanded(child: ListTile(visualDensity: VisualDensity.compact, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border50,),), tileColor: AppColors.floralWhite, title: Text(AppLocalizations.of(context)!.edit,), trailing: const Icon(Icons.add_circle, color: Colors.black),)),
                      const SizedBox(width: Dimens.width12),
                      Expanded(child: ListTile(visualDensity: VisualDensity.compact, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border50,),), tileColor: AppColors.floralWhite, title: Text(AppLocalizations.of(context)!.comment), trailing: const Icon(Icons.add_circle, color: Colors.black),)),
                    ],
                  ),
                  const SizedBox(height: Dimens.height32,),
                  RoundedBorderBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...nutrients.map((n) => Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),child: Column(
                          children: [
                            NutrientRow(label: n["label"]!, value: n["value"]!),
                          ],
                        ))),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.micronutrientss,
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeLarge,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...[].map((nutrient) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                          child: Column(
                            children: [
                              NutrientRow(label: nutrient.nutrientInfoMaster.translate(context), value: '${nutrient.quantityConsumed.toInt()} ${nutrient.unit}'),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}