import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_card.dart';
import '../widgets/control_panel.dart';
import '../../../services/firestore_service.dart';
import '../../../models/device_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _deviceId = 'plant_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Smart Plant Watering', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: StreamBuilder<DeviceModel>(
          stream: _firestoreService.getDeviceStream(_deviceId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Waiting for Firestore data...\nMake sure Firebase is configured\nand the document devices/plant_001 exists.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[400])),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Device not found.'));
            }

            final device = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, device),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildMetricsGrid(device: device, isWide: true)),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _buildControls(context, device)),
                          ],
                        )
                      else ...[
                        _buildMetricsGrid(device: device, isWide: false),
                        const SizedBox(height: 24),
                        _buildControls(context, device),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeviceModel device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Plant',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Device: ${device.id}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        StatusCard(status: device.online ? 'Online' : 'Offline', isOnline: device.online),
      ],
    );
  }

  Widget _buildMetricsGrid({required DeviceModel device, required bool isWide}) {
    return GridView.count(
      crossAxisCount: isWide ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        MetricCard(
          title: 'Soil Moisture',
          value: '${device.soilMoisture.toStringAsFixed(1)}%',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Temperature',
          value: '${device.temperature.toStringAsFixed(1)}°C',
          icon: Icons.thermostat,
          color: Colors.orange,
        ),
        MetricCard(
          title: 'Water Level',
          value: '${device.waterLevel.toStringAsFixed(1)}%',
          icon: Icons.waves,
          color: Colors.cyan,
        ),
        MetricCard(
          title: 'Pump Status',
          value: device.pump ? 'ON' : 'OFF',
          icon: Icons.power,
          color: device.pump ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, DeviceModel device) {
    return ControlPanel(
      deviceId: device.id,
      isAutomatic: device.automatic,
    );
  }
}
