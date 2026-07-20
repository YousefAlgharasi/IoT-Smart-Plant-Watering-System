import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class Esp32Simulator {
  final FirestoreService _firestoreService = FirestoreService();
  final String deviceId;
  Timer? _timer;
  final Random _random = Random();
  
  // Ambient target for realistic gradual temperature drift
  double _targetTemp = 24.0;

  Esp32Simulator(this.deviceId);

  void start() {
    // Update physical sensor readings every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final device = await _firestoreService.getDevice(deviceId);
        if (device == null) return;

        double newSoilMoisture = device.soilMoisture;
        double newWaterLevel = device.waterLevel;
        double newTemp = device.temperature;

        // 1. Temperature Simulation
        // Slowly drift towards a target ambient temperature
        if ((newTemp - _targetTemp).abs() < 0.5) {
          // Pick a new target between 20°C and 30°C once we reach the current target
          _targetTemp = 20.0 + _random.nextDouble() * 10.0;
        }
        
        // Move temp slightly towards target
        double tempDrift = (newTemp < _targetTemp) ? 0.2 : -0.2;
        // Add tiny random noise +/- 0.05
        tempDrift += (_random.nextDouble() - 0.5) * 0.1;
        newTemp += tempDrift;
        newTemp = newTemp.clamp(10.0, 45.0); // Realistic bounds

        // 2. Soil Moisture & Water Level Simulation
        if (device.pump) {
          // Pump is running: moisture goes up quickly, tank goes down
          newSoilMoisture += 5.0; // +5.0% per tick
          newWaterLevel -= 1.5;  // -1.5% per tick
        } else {
          // Pump off: moisture slowly evaporates
          newSoilMoisture -= 0.3; // -0.3% per tick
        }

        // Clamp values realistically between 0% and 100%
        newSoilMoisture = newSoilMoisture.clamp(0.0, 100.0);
        newWaterLevel = newWaterLevel.clamp(0.0, 100.0);

        // 3. Publish to Firestore
        await _firestoreService.updateDeviceFields(deviceId, {
          'soilMoisture': newSoilMoisture,
          'temperature': newTemp,
          'waterLevel': newWaterLevel,
          'online': true, // Keep heartbeat online
          'lastUpdated': Timestamp.now(), 
        });

      } catch (e) {
        debugPrint("ESP32 Simulator Error: $e");
      }
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
