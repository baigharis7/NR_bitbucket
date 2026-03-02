import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/screen_top_bar.dart';

class BarcodeDetailScreen extends StatelessWidget {
  static const routeName = '/bar_code_detail_screen';
  const BarcodeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenTopBar(
                    selectedDate: null,
                    onBack: () => Navigator.pop(context),
                  ),
                  SizedBox(height: Dimens.height32),
                  // Product Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://t4.ftcdn.net/jpg/03/40/59/61/360_F_340596198_RZ7WYwBq4LI12BfJZEE2AMOfWv0zNJOf.jpg',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Product Name
                  Text(
                    'Nutella - Hazelnut Spread',
                    style: TextStyle(color: Colors.white, fontSize: Dimens.fontSize20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12),

                  // Nutritional Info
                  Text('Nutritional Values per 100g', style: TextStyle(color: Colors.white, fontSize: Dimens.fontSizeLarge, fontWeight: FontWeight.w400)),
                  SizedBox(height: 8),

                  _buildNutrientRow("Energy", "125 kcal"),
                  _buildNutrientRow("Fat", "5 g"),
                  _buildNutrientRow("Saturated Fat", "20 g"),
                  _buildNutrientRow("Carbohydrates", "43 g"),
                  _buildNutrientRow("Sugars", "72 g"),
                  _buildNutrientRow("Fiber", "12 g"),
                  _buildNutrientRow("Proteins", "2 g"),
                  _buildNutrientRow("Salt", "0.02 g"),
                  _buildNutrientRow("Sodium", "8 mg"),
                  _buildNutrientRow("Vitamin B12", "98 µg"),
                  _buildNutrientRow("Vitamin C", "89 mg"),
                  _buildNutrientRow("Calcium", "210 mg"),

                  // Spacer(),

                  // Barcode (mock)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_2, size: 48, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("737628064502", style: TextStyle(letterSpacing: 2, color: Colors.white, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],);
  }

  Widget _buildNutrientRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Dimens.fontSizeLarge,)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: Dimens.fontSizeLarge,)),
        ],
      ),
    );
  }

}