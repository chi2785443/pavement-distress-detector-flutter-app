import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../provider/detection_history_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final detections = ref.watch(detectionHistoryProvider);

    final markers = detections
        .where((d) => d.latitude != null && d.longitude != null)
        .map(
          (entry) => Marker(
            markerId: MarkerId(entry.timestamp.toIso8601String()),
            position: LatLng(entry.latitude!, entry.longitude!),
            infoWindow: InfoWindow(title: entry.label, snippet: entry.result),
          ),
        )
        .toSet();

    final initialPosition =
        detections.isNotEmpty && detections.last.latitude != null
        ? CameraPosition(
            target: LatLng(
              detections.last.latitude!,
              detections.last.longitude!,
            ),
            zoom: 14,
          )
        : const CameraPosition(
            target: LatLng(9.0578, 7.4951), // Abuja fallback
            zoom: 14,
          );

    return Scaffold(
      appBar: AppBar(title: const Text("Detection Map")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: initialPosition,
        markers: markers,
      ),
    );
  }
}
