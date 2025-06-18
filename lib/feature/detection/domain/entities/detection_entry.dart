import "dart:io";

class DetectionEntry {
  final File image;
  final String label;
  final double confidence;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  DetectionEntry({
    required this.image,
    required this.label,
    required this.confidence,
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  String get result =>
      "$label (Confidence: ${(confidence * 100).toStringAsFixed(2)}%)";
}
