// detection_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/detection_entry.dart';

class DetectionHistoryNotifier extends StateNotifier<List<DetectionEntry>> {
  DetectionHistoryNotifier() : super([]);

  void addEntry(DetectionEntry entry) {
    state = [...state, entry];
  }
}

final detectionHistoryProvider =
    StateNotifierProvider<DetectionHistoryNotifier, List<DetectionEntry>>(
      (ref) => DetectionHistoryNotifier(),
    );
