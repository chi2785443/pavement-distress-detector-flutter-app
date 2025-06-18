import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavement_distress_detection/feature/detection/domain/entities/detection_entry.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import '../provider/detection_history_provider.dart';

class CapturedImageScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const CapturedImageScreen({super.key, required this.imageFile});

  @override
  ConsumerState<CapturedImageScreen> createState() =>
      _CapturedImageScreenState();
}

class _CapturedImageScreenState extends ConsumerState<CapturedImageScreen> {
  String? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _detectCapture(File imageFile) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final interpreter = await Interpreter.fromAsset(
        'assets/cnn_crack_detector.tflite',
      );

      final rawImage = File(imageFile.path).readAsBytesSync();
      final decodedImage = img.decodeImage(rawImage);

      if (decodedImage == null) {
        setState(() {
          _error = "Error decoding image.";
          _isLoading = false;
        });
        return;
      }

      final inputImage = img.copyResize(decodedImage, width: 224, height: 224);
      var input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final pixel = inputImage.getPixel(x, y);
            return [pixel.rNormalized, pixel.gNormalized, pixel.bNormalized];
          }),
        ),
      );

      var output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      interpreter.run(input, output);

      double confidence = output[0][0];
      String label = confidence > 0.5 ? "Crack Detected" : "No Crack";

      setState(() {
        _result =
            "$label\nConfidence: ${(confidence * 100).toStringAsFixed(2)}%";
        _isLoading = false;
      });

      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        }
        if (serviceEnabled && permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        rethrow;
      }

      final detectionEntry = DetectionEntry(
        image: imageFile,
        label: label,
        confidence: confidence,
        timestamp: DateTime.now(),
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      ref.read(detectionHistoryProvider.notifier).addEntry(detectionEntry);

      showResultBottomSheet(context, label, confidence);
    } catch (e) {
      setState(() {
        _error = "Error during detection: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captured Image"), elevation: 0),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      widget.imageFile,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            ),

          if (_error != null)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _detectCapture(widget.imageFile),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text(
                    "Run Detection",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showResultBottomSheet(
  BuildContext context,
  String label,
  double confidence,
) {
  final isCrack = label == "Crack Detected";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isCrack ? Icons.warning_amber_rounded : Icons.verified,
            size: 60,
            color: isCrack ? Colors.redAccent : Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isCrack ? Colors.redAccent : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text("Close"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
