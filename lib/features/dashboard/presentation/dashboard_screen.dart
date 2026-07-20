import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_card.dart';
import '../widgets/control_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMetricsGrid(isWide: true)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildControls(context)),
                      ],
                    )
                  else ...[
                    _buildMetricsGrid(isWide: false),
                    const SizedBox(height: 24),
                    _buildControls(context),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Device: plant_001',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const StatusCard(status: 'Online', isOnline: true),
      ],
    );
  }

  Widget _buildMetricsGrid({required bool isWide}) {
    return GridView.count(
      crossAxisCount: isWide ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: const [
        MetricCard(
          title: 'Soil Moisture',
          value: '45%',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Temperature',
          value: '24°C',
          icon: Icons.thermostat,
          color: Colors.orange,
        ),
        MetricCard(
          title: 'Water Level',
          value: '80%',
          icon: Icons.waves,
          color: Colors.cyan,
        ),
        MetricCard(
          title: 'Pump Status',
          value: 'OFF',
          icon: Icons.power,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return const ControlPanel(
      isAutomatic: true,
    );
  }
}
