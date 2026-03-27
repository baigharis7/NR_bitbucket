import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_state.dart';

/// Food scanner screen with camera preview and results overlay.
///
/// Uses the device camera for:
/// - **Barcode scanning**: ML Kit detects barcodes in real-time from camera frames
/// - **Visual food recognition**: User taps capture → photo sent to Claude Vision API
///
/// Returns a [List<FoodInFavorite>] via Navigator.pop when the user
/// confirms food selection (either via "Log selected" or after editing).
class FoodScannerScreen extends StatefulWidget {
  final int mealType;

  const FoodScannerScreen({super.key, required this.mealType});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _isOffline = false;

  // ML Kit barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isProcessingFrame = false;
  String? _lastScannedBarcode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnectivity();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
      setState(() => _isCameraInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
      _initializeCamera();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (mounted) setState(() => _isOffline = result.isEmpty);
    } on SocketException catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() => _isCameraInitialized = true);

      // Start barcode scanning from camera stream
      _startBarcodeScanning();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _startBarcodeScanning() {
    _cameraController?.startImageStream((image) {
      if (_isProcessingFrame) return;
      _isProcessingFrame = true;
      _processCameraFrame(image).whenComplete(() {
        _isProcessingFrame = false;
      });
    });
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isEmpty || !mounted) return;

      final barcode = barcodes.first;
      final value = barcode.rawValue;
      if (value == null || value == _lastScannedBarcode) return;

      // Avoid re-scanning the same barcode
      _lastScannedBarcode = value;

      // Stop the image stream while processing
      await _cameraController?.stopImageStream();

      if (mounted) {
        context
            .read<FoodScannerBloc>()
            .add(OnBarcodeDetectedAction(barcode: value));
      }
    } catch (_) {
      // Silently handle ML Kit errors (e.g., bad frame)
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation rotation;
    switch (sensorOrientation) {
      case 0:
        rotation = InputImageRotation.rotation0deg;
        break;
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    // Concatenate all YUV420 planes into a single byte array
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      // Stop image stream before taking picture
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }

      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      if (mounted) {
        context
            .read<FoodScannerBloc>()
            .add(CapturePhotoAction(imageBytes: bytes));
      }
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodScannerBloc, FoodScannerState>(
      listener: (context, state) {
        if (state.editingIndex != null) {
          _navigateToEditFood(context, state);
        }
        // Resume barcode scanning after reset or when results are cleared
        if (!state.hasResults &&
            !state.isProcessing &&
            _cameraController != null &&
            _cameraController!.value.isInitialized &&
            !_cameraController!.value.isStreamingImages) {
          _lastScannedBarcode = null;
          _startBarcodeScanning();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Camera preview area
              _buildCameraPreview(),

              // Close button (top right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: _buildCloseButton(context),
              ),

              // Viewfinder frame
              if (!state.hasResults) _buildViewfinder(),

              // Processing indicator
              if (state.isProcessing) _buildProcessingIndicator(),

              // Offline banner
              if (_isOffline) _buildOfflineBanner(),

              // Capture button (bottom center) — only when no results
              if (!state.hasResults && !state.isProcessing)
                _buildCaptureButton(),

              // Results bottom sheet
              if (state.hasResults) _buildResultsSheet(context, state),

              // Error message
              if (state.errorMessage != null)
                _buildErrorBanner(state.errorMessage!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.mountainMeadow),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.black25Percent,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildViewfinder() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.mountainMeadow),
          SizedBox(height: 16),
          Text(
            'Scanning...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 52,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orangeAccent, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No internet connection. Scanning requires an active connection.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    final disabled = _isOffline;
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 40,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: disabled ? null : _capturePhoto,
          child: Opacity(
            opacity: disabled ? 0.35 : 1.0,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: Colors.white24,
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSheet(BuildContext context, FoodScannerState state) {
    final bloc = context.read<FoodScannerBloc>();
    final hasEdited = state.editedFoods.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.yellowishGreen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.white50Percent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => bloc.add(ResetScannerAction()),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                          color: AppColors.white70Percent, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the food you would like to log.',
                style:
                    TextStyle(color: AppColors.white70Percent, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Food results list
              ...state.results.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = state.selectedIndices.contains(index);
                return _buildFoodResultTile(
                  context,
                  item.scanResult,
                  isSelected,
                  () =>
                      bloc.add(ToggleFoodSelectionAction(index: index)),
                );
              }),

              const SizedBox(height: 12),

              // "Search Manually" link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Not what you are looking for? Search Manually',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Search again',
                      isPrimary: false,
                      onTap: () => bloc.add(ResetScannerAction()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (state.hasSelection) ...[
                    Expanded(
                      child: _buildActionButton(
                        label: hasEdited ? 'Continue' : 'Edit',
                        isPrimary: false,
                        onTap: () =>
                            bloc.add(EditNextSelectedFoodAction()),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _buildActionButton(
                      label: 'Log selected',
                      isPrimary: true,
                      onTap: state.hasSelection
                          ? () => _logSelectedFoods(context, state)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFoodResultTile(
    BuildContext context,
    ScanResult result,
    bool isSelected,
    VoidCallback onToggle,
  ) {
    final displayName = result.isMatched
        ? result.matchedNameEn ?? result.scannedName
        : result.scannedName;
    final kcalText = result.estimatedKcal != null
        ? 'Energy: ${result.estimatedKcal!.round()} kcal.'
        : '';
    final amountText = result.estimatedGrams != null
        ? ' - Amount: ${result.estimatedGrams!.round()} gr.'
        : '';

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.yellowishGreen80,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.mountainMeadow
                : AppColors.white25Percent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (kcalText.isNotEmpty || amountText.isNotEmpty)
                    Text(
                      '$kcalText$amountText',
                      style: const TextStyle(
                        color: AppColors.white70Percent,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.mountainMeadow
                    : Colors.transparent,
                border:
                    Border.all(color: AppColors.white50Percent, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.mountainMeadow : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPrimary
                ? AppColors.mountainMeadow
                : AppColors.white50Percent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  onTap != null ? Colors.white : AppColors.white50Percent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _logSelectedFoods(BuildContext context, FoodScannerState state) {
    final selectedFoods = <FoodInFavorite>[];
    for (final index in state.selectedIndices) {
      final result = state.results[index].scanResult;
      selectedFoods.add(_scanResultToFoodInFavorite(result));
    }
    Navigator.pop(context, selectedFoods);
  }

  void _navigateToEditFood(BuildContext context, FoodScannerState state) {
    final editIndex = state.editingIndex!;
    final result = state.results[editIndex].scanResult;
    final food = _scanResultToFoodInFavorite(result);

    // Navigate to AddFoodEventScreen with this food pre-loaded.
    // The route name and arguments depend on the existing navigation setup.
    // For now, we pop with a single food marked for editing.
    Navigator.pop(context, [food]);
  }

  FoodInFavorite _scanResultToFoodInFavorite(ScanResult result) {
    final int foodId;
    final String? nameEn;
    final String? nameEs;

    if (result.isMatched) {
      foodId = result.matchedFoodId!;
      nameEn = result.matchedNameEn;
      nameEs = result.matchedNameEs;
    } else {
      // For unmatched foods, the negative ID was assigned when caching.
      // Look it up from the barcode cache or assign a temporary one.
      foodId = -1; // TODO: resolve from ScannedFoodRepository cache
      nameEn = result.scannedName;
      nameEs = result.scannedName;
    }

    return FoodInFavorite(
      id: foodId,
      name_en: nameEn,
      name_es: nameEs,
      qty: (result.estimatedGrams ?? 100).round(),
      unit: 0, // grams (unit ID 0 typically)
      cookingMethod: 0, // no cooking method
    );
  }
}
