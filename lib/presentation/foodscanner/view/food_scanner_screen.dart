import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_state.dart';

/// Food scanner screen with camera preview and results overlay.
///
/// Uses the device camera for:
/// - **Barcode scanning**: ML Kit detects barcodes in real-time from camera frames
/// - **Visual food recognition**: User taps capture → photo sent to LogMeal API
///
/// Returns a [ScannerResult] via Navigator.pop when the user confirms food
/// selection. [ScannerResult.directLog] distinguishes "Log selected" (save
/// immediately) from "Edit" (open AddFoodEventScreen for editing).
class FoodScannerScreen extends StatefulWidget {
  final int mealType;

  const FoodScannerScreen({super.key, required this.mealType});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  /// Frozen image bytes shown while scanning is in progress.
  Uint8List? _capturedImageBytes;

  // ML Kit barcode scanner (used on captured photo, not live stream)
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  // Focus ring
  Offset? _focusPoint;
  late AnimationController _focusAnimController;
  late Animation<double> _focusAnimation;

  /// Tracks saveTick from the last frame so we can detect increments.
  int _lastSeenSaveTick = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _focusAnimation = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(parent: _focusAnimController, curve: Curves.easeOut),
    );
    _initializeCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<FoodScannerBloc>()
          .add(InitializeMealTypeAction(mealType: widget.mealType));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusAnimController.dispose();
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
      _initializeCamera();
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
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  /// Try barcode detection on the captured JPEG file.
  /// Returns the barcode value if found, null otherwise.
  Future<String?> _detectBarcodeInImage(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final value = barcodes.first.rawValue;
        if (value != null && value.isNotEmpty) {
          debugPrint('[Scanner] Barcode detected in photo: $value');
          return value;
        }
      }
    } catch (e) {
      debugPrint('[Scanner] Barcode detection error: $e');
    }
    return null;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      if (!mounted) return;
      setState(() => _capturedImageBytes = bytes);

      final bloc = context.read<FoodScannerBloc>();

      // Try barcode detection first, then fall back to visual recognition
      final barcode = await _detectBarcodeInImage(xFile.path);
      if (barcode != null && mounted) {
        bloc.add(OnBarcodeDetectedAction(barcode: barcode));
      } else if (mounted) {
        bloc.add(CapturePhotoAction(imageBytes: bytes));
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
        // Clear frozen image when results arrive or on error
        if (!state.isProcessing && _capturedImageBytes != null) {
          setState(() => _capturedImageBytes = null);
        }

        // A save finished — show splash
        if (state.saveTick != _lastSeenSaveTick) {
          _lastSeenSaveTick = state.saveTick;
          _showSaveSplash(context);
        }

        // Error toast
        final error = state.errorMessage;
        if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(error)));
        }

        // Edit requested — push a pre-filled AddFoodEventScreen on top
        // of the scanner so the user returns here after save/back.
        if (state.editingIndex != null) {
          final index = state.editingIndex!;
          final scan = state.results[index].scanResult;
          context.read<FoodScannerBloc>().add(ClearEditingAction());
          _pushEditScreen(context, scan, index);
          return;
        }

        // List is empty after a save — navigate the parent back to the
        // meal summary instead of the (now-empty) AddFoodEventScreen.
        if (state.navigateToSummary) {
          context.read<FoodScannerBloc>().add(ClearNavigateToSummaryAction());
          Navigator.pop(context, true);
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
    // Show frozen captured image while scanning
    if (_capturedImageBytes != null) {
      return SizedBox.expand(
        child: Image.memory(
          _capturedImageBytes!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.mountainMeadow),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPoint = renderBox.globalToLocal(details.globalPosition);
        final size = renderBox.size;
        final x = localPoint.dx / size.width;
        final y = localPoint.dy / size.height;
        final point = Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
        try {
          _cameraController!.setFocusPoint(point);
          _cameraController!.setExposurePoint(point);
          _cameraController!.setFocusMode(FocusMode.auto);
        } catch (_) {
          // Some devices don't support focus/exposure point
        }
        // Show focus ring at tap position
        setState(() => _focusPoint = localPoint);
        _focusAnimController.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _focusPoint = null);
        });
      },
      child: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 30,
              top: _focusPoint!.dy - 30,
              child: AnimatedBuilder(
                animation: _focusAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _focusAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Pop with `true` if the user has logged anything this session so
  /// the parent screen can navigate to the meal summary; otherwise pop
  /// with `null` so the user lands back on the add-food screen.
  void _closeScanner(BuildContext context) {
    final didLog = context.read<FoodScannerBloc>().state.hasLoggedSomething;
    Navigator.pop(context, didLog ? true : null);
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeScanner(context),
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
    final padding = MediaQuery.of(context).padding;
    // Close button: top + 8 + 36px. Capture button: bottom + 40 + 72px.
    final topEdge = padding.top + 8 + 36;
    final bottomEdge = padding.bottom + 40 + 72;
    // Equal gap from close button and capture button
    const gap = 20.0;
    final top = topEdge + gap;
    final bottom = bottomEdge + gap;
    const horizontalInset = 24.0;
    const cornerLen = 32.0;
    const strokeWidth = 3.0;
    const color = Colors.white70;

    return Positioned(
      top: top,
      bottom: bottom,
      left: horizontalInset,
      right: horizontalInset,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CornerBracketPainter(
            color: color,
            strokeWidth: strokeWidth,
            cornerLength: cornerLen,
            radius: 12,
          ),
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
            'Scanning... please wait',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 40,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _capturePhoto,
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
    );
  }

  Widget _buildResultsSheet(BuildContext context, FoodScannerState state) {
    final bloc = context.read<FoodScannerBloc>();

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
          child: Column(
            children: [
              // Fixed header section (not scrollable)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    // Header: "Results" on the left, "Scan again" on the right.
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
                          onTap: state.isSaving
                              ? null
                              : () => bloc.add(ResetScannerAction()),
                          child: const Text(
                            'Scan again',
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
                    const SizedBox(height: 10),

                    // Manual search link, right under the subtitle.
                    Center(
                      child: GestureDetector(
                        onTap: () => _closeScanner(context),
                        child: const Text(
                          'Not what you are looking for? Search Manually',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Scrollable food results list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
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
                  ],
                ),
              ),

              // Fixed action buttons (not scrollable)
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    // Row 1: Clear | Edit | Log
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Clear',
                            isPrimary: false,
                            onTap: state.hasResults && !state.isSaving
                                ? () => bloc.add(ResetScannerAction())
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Edit',
                            isPrimary: false,
                            onTap: state.hasSelection && !state.isSaving
                                ? () => bloc.add(EditTopmostAction())
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Log',
                            isPrimary: true,
                            onTap: state.hasSelection && !state.isSaving
                                ? () => bloc.add(LogTopmostAction())
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Done | Log all (equal size)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Done',
                            isPrimary: false,
                            onTap: state.isSaving
                                ? null
                                : () => _onDonePressed(context, state),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Log all',
                            isPrimary: true,
                            onTap: state.hasSelection && !state.isSaving
                                ? () => _onLogAllPressed(context, state)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    final subtitleParts = <String>[];
    if (result.estimatedGrams != null) {
      subtitleParts.add('~${result.estimatedGrams!.round()} g');
    } else {
      subtitleParts.add('Amount needed');
    }
    if (result.estimatedKcal != null) {
      subtitleParts.add('~${result.estimatedKcal!.round()} kcal');
    }
    if (result.isMatched) {
      subtitleParts.add('Matched');
    }
    if (result.detectedCookingMethod != null) {
      subtitleParts.add(result.detectedCookingMethod!);
    }
    final subtitleText = subtitleParts.join(' · ');

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
                  if (subtitleText.isNotEmpty)
                    Text(
                      subtitleText,
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

  /// Log all when every checked row has a gram estimate; otherwise
  /// fall through to the edit flow for the topmost gramless row.
  void _onLogAllPressed(BuildContext context, FoodScannerState state) {
    final bloc = context.read<FoodScannerBloc>();
    final anyMissingGrams = state.selectedIndices.any((i) =>
        i < state.results.length &&
        state.results[i].scanResult.estimatedGrams == null);
    if (anyMissingGrams) {
      bloc.add(EditTopmostAction());
    } else {
      bloc.add(LogAllAction());
    }
  }

  /// End the scan session. If the user still has rows checked, confirm
  /// first since those rows would not be logged.
  Future<void> _onDonePressed(
      BuildContext context, FoodScannerState state) async {
    if (state.hasSelection) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Finish logging?'),
          content: const Text(
              'You still have items selected. Finishing now will not log them.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Finish'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (!context.mounted) return;
    // Done always navigates the parent to the summary, regardless of
    // whether anything was logged in this session.
    Navigator.pop(context, true);
  }

  /// Show the same ConfirmationDialog the rest of the app uses after
  /// a successful log, then auto-dismiss it.
  void _showSaveSplash(BuildContext context) {
    final mealTimeIcon = 'assets/images/meal_time_${widget.mealType}.png';
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        message: AppLocalizations.of(ctx)!.food_event_successfully_saved,
        iconAsset: mealTimeIcon,
      ),
    );
  }

  /// Push a pre-filled AddFoodEventScreen on top of the scanner so the
  /// user edits one food and returns here. On save the screen pops
  /// with `true`; on back it pops with `null`.
  Future<void> _pushEditScreen(
    BuildContext context,
    ScanResult scan,
    int index,
  ) async {
    final bloc = context.read<FoodScannerBloc>();

    // Route through the same mapper used by the Log path so unmatched scans
    // get their per-100g nutrients persisted to Drift and are assigned a
    // stable negative food id. Otherwise the edited event saves with a
    // bogus id, enrichment can't find the composition, and the saved row
    // ends up with 0 kcal and no amount.
    final ingredient = await bloc.scanResultMapper.toIngredient(scan);

    if (!context.mounted) return;

    final prefill = FoodFavorite(
      ingredients: [ingredient],
      drinks: [],
      mealTime: widget.mealType,
      title: ingredient.name_en ?? scan.scannedName,
    );

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: AddFoodEventScreen.routeName,
          arguments: prefill,
        ),
        builder: (_) => const AddFoodEventScreen(popOnSave: true),
      ),
    );

    if (!context.mounted) return;
    if (saved == true) {
      bloc.add(EditCompletedAction(index: index));
    } else {
      // User backed out — let the bloc abort any in-flight Log all batch
      // so it doesn't auto-resume on a later, unrelated edit.
      bloc.add(EditCancelledAction());
    }
  }
}

/// Draws four corner brackets (L-shapes) around a rectangle.
class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  _CornerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final c = cornerLength;
    final r = radius;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, c)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(c, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - c, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, c),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, h - c)
        ..lineTo(0, h - r)
        ..quadraticBezierTo(0, h, r, h)
        ..lineTo(c, h),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - c, h)
        ..lineTo(w - r, h)
        ..quadraticBezierTo(w, h, w, h - r)
        ..lineTo(w, h - c),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      cornerLength != old.cornerLength ||
      radius != old.radius;
}
