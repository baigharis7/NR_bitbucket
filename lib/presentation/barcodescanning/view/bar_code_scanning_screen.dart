import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../barcodedetail/view/bar_code_detail_screen.dart';

class BarCodeScanningScreen extends StatefulWidget {
  static const routeName = '/bar_code_scanning_screen';
  const BarCodeScanningScreen({super.key});

  @override
  State<BarCodeScanningScreen> createState() => _BarCodeScanningScreenState();
}

class _BarCodeScanningScreenState extends State<BarCodeScanningScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String? scannedCode;

  void _handleBarcodeCapture(BarcodeCapture capture) {
    if (!isScanning) return;

    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          scannedCode = code;
          isScanning = false;
        });

        debugPrint('Scanned: $code');
        Navigator.pushNamed(context, BarcodeDetailScreen.routeName);
        // showDialog(
        //   context: context,
        //   builder: (_) => AlertDialog(
        //     title: const Text('Scanned Code'),
        //     content: Text(code),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //           setState(() {
        //             isScanning = true; // Re-enable scanning
        //           });
        //         },
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );

        break;
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: AppColors.darkJungleGreen,
       title: const Text('Barcode Scanner'),
       actions: [
         IconButton(
           icon: const Icon(Icons.flash_on),
           onPressed: () => cameraController.toggleTorch(),
         ),
       ],
     ),
     body: Stack(
       children: [
         MobileScanner(
           controller: cameraController,
           onDetect: _handleBarcodeCapture,
         ),
         if (scannedCode != null)
           Align(
             alignment: Alignment.bottomCenter,
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Text(
                 'Last scanned: $scannedCode',
                 style: const TextStyle(color: Colors.white),
               ),
             ),
           ),
       ],
     ),
   );
  }
}