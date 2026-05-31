import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

class BarCodeScanningScreen extends StatelessWidget {
  static const routeName = '/bar_code_scanning_screen';
  const BarCodeScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkJungleGreen,
        title: Text(l10n.barcode_scanner_title),
      ),
      body: Center(
        child: Text(l10n.barcode_scanner_unavailable),
      ),
    );
  }
}
