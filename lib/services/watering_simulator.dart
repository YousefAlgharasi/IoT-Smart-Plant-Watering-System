import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AutomaticWateringSimulator {
  final FirestoreService _firestoreService = FirestoreService();
  final String deviceId;
  Timer? _timer;
  bool _isWatering = false;

  AutomaticWateringSimulator(this.deviceId);

  void start() {
    // Poll every 3 seconds to check the conditions
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // The algorithm should never start another watering cycle while one is already running
      if (_isWatering) return;

      try {
        final device = await _firestoreService.getDevice(deviceId);
        if (device == null) return;

        // If the pump is already on (e.g. manually triggered), do not start another cycle
        if (device.pump) return;

        // Logic: If automatic == true AND soilMoisture < threshold
        if (device.automatic && device.soilMoisture < device.threshold) {
          _performWatering(device.wateringDuration);
        }
      } catch (e) {
        debugPrint("AutomaticWateringSimulator Error: $e");
      }
    });
  }

  Future<void> _performWatering(int durationInSeconds) async {
    _isWatering = true;
    try {
      debugPrint("Simulation: Starting pump...");
      // Start watering
      await _firestoreService.updateDeviceFields(deviceId, {'pump': true});
      
      // During watering: wait wateringDuration seconds
      await Future.delayed(Duration(seconds: durationInSeconds));
      
      debugPrint("Simulation: Stopping pump...");
      // After wateringDuration seconds: set pump = false
      await _firestoreService.updateDeviceFields(deviceId, {'pump': false});
    } catch (e) {
      debugPrint("Simulation: Error during watering cycle: $e");
    } finally {
      _isWatering = false;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}
