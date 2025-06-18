import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/camera_provider.dart';
import 'captured_image_screen.dart'; // Make sure this path is correct

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {}); // Rebuild when camera is ready
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturedImage = ref.watch(capturedImageProvider);

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Live camera preview
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1080,
                height: _controller!.value.previewSize?.width ?? 720,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // Capture Button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text("Capture", style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    await _handleCapture(context, ref);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCapture(BuildContext context, WidgetRef ref) async {
    try {
      final file = await _controller!.takePicture();
      final imageFile = File(file.path);
      ref.read(capturedImageProvider.notifier).state = imageFile;

      // Navigate to captured image screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapturedImageScreen(imageFile: imageFile),
        ),
      );
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }
}
