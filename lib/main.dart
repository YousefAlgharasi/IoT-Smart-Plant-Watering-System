import 'package:flutter/material.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization goes here later
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
