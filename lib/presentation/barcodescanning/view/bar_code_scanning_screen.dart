import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

class BarCodeScanningScreen extends StatelessWidget {
  static const routeName = '/bar_code_scanning_screen';
  const BarCodeScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkJungleGreen,
        title: const Text('Barcode Scanner'),
      ),
      body: const Center(
        child: Text('Barcode scanning is currently unavailable.'),
      ),
    );
  }
}
