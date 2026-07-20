import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final double soilMoisture;
  final double temperature;
  final double waterLevel;
  final bool pump;
  final bool automatic;
  final bool online;
  final double threshold;
  final int wateringDuration;
  final DateTime lastUpdated;

  DeviceModel({
    required this.id,
    required this.soilMoisture,
    required this.temperature,
    required this.waterLevel,
    required this.pump,
    required this.automatic,
    required this.online,
    required this.threshold,
    required this.wateringDuration,
    required this.lastUpdated,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      soilMoisture: (data['soilMoisture'] ?? 0.0).toDouble(),
      temperature: (data['temperature'] ?? 0.0).toDouble(),
      waterLevel: (data['waterLevel'] ?? 0.0).toDouble(),
      pump: data['pump'] ?? false,
      automatic: data['automatic'] ?? false,
      online: data['online'] ?? false,
      threshold: (data['threshold'] ?? 0.0).toDouble(),
      wateringDuration: data['wateringDuration'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'soilMoisture': soilMoisture,
      'temperature': temperature,
      'waterLevel': waterLevel,
      'pump': pump,
      'automatic': automatic,
      'online': online,
      'threshold': threshold,
      'wateringDuration': wateringDuration,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
