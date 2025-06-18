import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final cameraControllerProvider = FutureProvider<CameraController>((ref) async {
//   final cameras = await availableCameras();
//   final frontCamera = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.back,
//     orElse: () => cameras.first,
//   );
//
//   final controller = CameraController(
//     frontCamera,
//     ResolutionPreset.medium,
//     enableAudio: false,
//   );
//
//
//   await controller.initialize();
//   return controller;
// });

final cameraControllerProvider = FutureProvider<CameraController>((ref) async {
  final cameras = await availableCameras();
  final controller = CameraController(
    cameras[0],
    ResolutionPreset.max,
    enableAudio: false,
  );

  await controller.initialize();
  return controller;
});




final capturedImageProvider = StateProvider<File?>((ref) => null);

