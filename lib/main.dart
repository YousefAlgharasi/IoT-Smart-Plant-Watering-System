import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'services/watering_simulator.dart';
import 'services/esp32_simulator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Note: If you want to configure Firebase for all platforms using flutterfire CLI, 
    // run `flutterfire configure` and then pass `options: DefaultFirebaseOptions.currentPlatform`
    await Firebase.initializeApp();

    // Start the IoT simulated algorithm
    final algoSimulator = AutomaticWateringSimulator('plant_001');
    algoSimulator.start();

    // Start the ESP32 physical sensor simulator
    final espSimulator = Esp32Simulator('plant_001');
    espSimulator.start();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const SmartPlantApp());
}

class SmartPlantApp extends StatelessWidget {
  const SmartPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Watering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
