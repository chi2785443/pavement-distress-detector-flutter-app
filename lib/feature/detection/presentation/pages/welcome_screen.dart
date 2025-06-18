import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/detection_history_provider.dart';

class DetectionResult {
  final File image;
  final String result;

  DetectionResult({required this.image, required this.result});
}

class WelcomePage extends StatelessWidget {
  final List<DetectionResult> previousDetections = [
    DetectionResult(
      image: File('images/crack.jpeg'), // Replace with real path
      result: 'Crack Detected',
    ),
    DetectionResult(
      image: File('images/non cracked.jpeg'), // Replace with real path
      result: 'No Distress',
    ),
    // Add more detections as needed
  ];

  final double detected = 70;
  final double undetected = 30;

  WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Pavement Distress Detector"),
        backgroundColor: Colors.black38,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAnalyticsCard(),
            const SizedBox(height: 24),
            _buildDetectionList(),
            DetectionHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Detection Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: detected,
                      title: '${detected.toInt()}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: undetected,
                      title: '${undetected.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _Legend(color: Colors.green, text: "Detected"),
                SizedBox(width: 12),
                _Legend(color: Colors.redAccent, text: "Undetected"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detection Types',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          itemCount: previousDetections.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = previousDetections[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(item.image.path, fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  item.result,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.result.contains("Crack")
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                subtitle: Text(
                  item.result == "Crack Detected"
                      ? "There is crack in the image"
                      : "Little crack detected",
                ),
                trailing: Icon(
                  item.result == "Crack Detected"
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle,
                  size: 20,
                  color: item.result == "Crack Detected"
                      ? Colors.redAccent
                      : Colors.green,
                ),
                onTap: () {
                  // You can navigate to a detailed image page here
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class DetectionHistoryList extends ConsumerWidget {
  const DetectionHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previousDetections = ref.watch(detectionHistoryProvider);

    if (previousDetections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detection History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'No detections yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Detection History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          itemCount: previousDetections.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = previousDetections[index];
            final isCrack = item.label == "Crack Detected";

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(item.image, fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCrack ? Colors.red : Colors.green,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Confidence: ${(item.confidence * 100).toStringAsFixed(2)}%",
                    ),
                    Text(
                      "Date: ${item.timestamp.toLocal().toString().split('.')[0]}",
                    ),
                    if (item.latitude != null && item.longitude != null)
                      Text(
                        "Location: ${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}",
                      ),
                  ],
                ),
                trailing: Icon(
                  isCrack ? Icons.warning_amber_rounded : Icons.check_circle,
                  size: 20,
                  color: isCrack ? Colors.redAccent : Colors.green,
                ),
                onTap: () {
                  // Optionally show details
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
