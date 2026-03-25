import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../l10n/app_localizations.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isHandled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

void _onDetect(BarcodeCapture capture) {
  if (_isHandled) return;

  if (capture.barcodes.isEmpty) return;
  final barcode = capture.barcodes.first;

  final raw = barcode.rawValue?.trim();
  if (raw == null || raw.isEmpty) return;

  debugPrint('SCAN RESULT: format=${barcode.format}, value=$raw');

  _isHandled = true;
  Navigator.of(context).pop(raw); // HomeView-ə qaytarırıq
}

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.scanCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera + skan
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay (ortada çərçivə)
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final overlayWidth = screenWidth > 600
                    ? screenWidth * 0.5  // tablet
                    : screenWidth * 0.78; // phone
                final overlayHeight = overlayWidth * 0.53;
                return Container(
                  width: overlayWidth,
                  height: overlayHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          ),

          // Aşağıda yardımçı mətn
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                l.scanHint,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
